import Foundation
import SwiftUI

/// Single source of truth for everything that survives between launches:
/// the child profile(s), per-unit progress, and the gamification state (XP,
/// streak, badges, days played). Same shape as Fernby's ProgressStore —
/// UserDefaults + Codable, namespaced keys, auto-persist on `didSet` — so
/// the two apps stay mentally interchangeable.
///
/// v1 scopes progress to the single active profile (a flat store, not
/// per-profile maps). That's a deliberate limitation matching Fernby v0.1;
/// multi-child isolation is a fast-follow.
@MainActor
final class ProgressStore: ObservableObject {
    static let shared = ProgressStore()

    private let defaults = UserDefaults.standard

    private enum Key {
        static let profiles       = "sprocket.profiles"
        static let activeProfile  = "sprocket.activeProfileID"
        static let unitProgress   = "sprocket.unitProgress"
        static let xp             = "sprocket.xp"
        static let currentStreak  = "sprocket.currentStreak"
        static let longestStreak  = "sprocket.longestStreak"
        static let lastPlayedDay  = "sprocket.lastPlayedDay"
        static let playedDays     = "sprocket.playedDays"
        static let badges         = "sprocket.badges"
        static let narration      = "sprocket.narrationEnabled"
    }

    // XP awarded per finished screen-type. Small numbers, frequent wins.
    static let xpPerUnit = 20

    @Published var profiles: [LearnerProfile] {
        didSet { persist(profiles, forKey: Key.profiles) }
    }
    @Published var activeProfileID: UUID? {
        didSet { defaults.set(activeProfileID?.uuidString, forKey: Key.activeProfile) }
    }
    @Published var unitProgress: [String: UnitProgress] {
        didSet { persist(unitProgress, forKey: Key.unitProgress) }
    }
    @Published var xp: Int {
        didSet { defaults.set(xp, forKey: Key.xp) }
    }
    @Published var currentStreak: Int {
        didSet { defaults.set(currentStreak, forKey: Key.currentStreak) }
    }
    @Published var longestStreak: Int {
        didSet { defaults.set(longestStreak, forKey: Key.longestStreak) }
    }
    @Published var lastPlayedDay: String? {
        didSet { defaults.set(lastPlayedDay, forKey: Key.lastPlayedDay) }
    }
    @Published var playedDays: Set<String> {
        didSet { persist(playedDays, forKey: Key.playedDays) }
    }
    @Published var earnedBadges: Set<String> {
        didSet { persist(earnedBadges, forKey: Key.badges) }
    }
    @Published var narrationEnabled: Bool {
        didSet { defaults.set(narrationEnabled, forKey: Key.narration) }
    }

    private init() {
        profiles        = Self.load(forKey: Key.profiles, from: defaults) ?? []
        activeProfileID = UUID(uuidString: defaults.string(forKey: Key.activeProfile) ?? "")
        unitProgress    = Self.load(forKey: Key.unitProgress, from: defaults) ?? [:]
        xp              = defaults.integer(forKey: Key.xp)
        currentStreak   = defaults.integer(forKey: Key.currentStreak)
        longestStreak   = defaults.integer(forKey: Key.longestStreak)
        lastPlayedDay   = defaults.string(forKey: Key.lastPlayedDay)
        playedDays      = Self.load(forKey: Key.playedDays, from: defaults) ?? []
        earnedBadges    = Self.load(forKey: Key.badges, from: defaults) ?? []
        narrationEnabled = defaults.object(forKey: Key.narration) as? Bool ?? false
    }

    // MARK: - Profile

    var activeProfile: LearnerProfile? {
        profiles.first { $0.id == activeProfileID }
    }

    /// The tier the app is currently teaching. Falls back to Sprouts only if
    /// somehow called before onboarding (never shown to a user in that state).
    var tier: Tier { activeProfile?.tier ?? .sprouts }

    var track: [Unit] { Curriculum.track(for: tier) }

    func createProfile(name: String, tier: Tier) {
        let profile = LearnerProfile(name: name.isEmpty ? tier.name : name, tier: tier)
        profiles.append(profile)
        activeProfileID = profile.id
        narrationEnabled = tier.narrationOnByDefault
    }

    // MARK: - Unit progress & unlocking

    func progress(for unitID: String) -> UnitProgress {
        unitProgress[unitID] ?? UnitProgress(unitID: unitID)
    }

    func isCompleted(_ unitID: String) -> Bool {
        progress(for: unitID).completed
    }

    /// A unit is open if it's the first in the track or the one before it is
    /// done. Strictly linear in v1 — a clear single path up the map.
    func isUnlocked(_ unit: Unit) -> Bool {
        if unit.order <= 1 { return true }
        let previous = track.first { $0.order == unit.order - 1 }
        return previous.map { isCompleted($0.id) } ?? true
    }

    /// The next unit a child should tackle: the first unlocked, not-yet-done
    /// unit in their track.
    var nextUnit: Unit? {
        track.first { isUnlocked($0) && !isCompleted($0.id) } ?? track.first
    }

    var completedCount: Int {
        track.filter { isCompleted($0.id) }.count
    }

    // MARK: - Completing a unit (the reward moment)

    /// Called by the lesson player when a unit is finished. Records stars &
    /// XP, advances the daily streak, and evaluates any newly-earned badges.
    /// Returns the badges earned *by this completion* so the player can
    /// celebrate them.
    @discardableResult
    func completeUnit(_ unit: Unit, correct: Int, total: Int) -> [Badge] {
        var p = progress(for: unit.id)
        let stars = Self.stars(correct: correct, total: total)
        // Never regress a child's best result on replay.
        p.stars = max(p.stars, stars)
        if !p.completed { xp += Self.xpPerUnit }
        p.completed = true
        p.completedAt = Date()
        unitProgress[unit.id] = p

        recordPlayToday()
        return awardBadges(justFinished: unit)
    }

    static func stars(correct: Int, total: Int) -> Int {
        guard total > 0 else { return 3 }
        let ratio = Double(correct) / Double(total)
        switch ratio {
        case 1.0:        return 3
        case 0.6...:     return 2
        default:         return 1   // finishing always earns at least one
        }
    }

    private func recordPlayToday() {
        let today = Self.dayKey(Date())
        guard lastPlayedDay != today else { return }   // already counted today
        if let last = lastPlayedDay, last == Self.dayKey(Date().addingTimeInterval(-86_400)) {
            currentStreak += 1
        } else {
            currentStreak = 1
        }
        longestStreak = max(longestStreak, currentStreak)
        lastPlayedDay = today
        playedDays.insert(today)
    }

    // MARK: - Badges

    private func awardBadges(justFinished unit: Unit) -> [Badge] {
        var newly: [Badge] = []
        func grant(_ badge: Badge) {
            guard !earnedBadges.contains(badge.rawValue) else { return }
            earnedBadges.insert(badge.rawValue)
            newly.append(badge)
        }

        if completedCount >= 1 { grant(.firstStep) }
        if completedCount >= 5 { grant(.curiousMind) }
        if currentStreak >= 3  { grant(.threeInARow) }
        if currentStreak >= 7  { grant(.weekStreak) }

        let ideaUnits = Curriculum.units(in: tier, idea: unit.bigIdea)
        if !ideaUnits.isEmpty, ideaUnits.allSatisfy({ isCompleted($0.id) }) {
            grant(.ideaMaster)
        }
        if track.allSatisfy({ isCompleted($0.id) }) { grant(.graduate) }

        return newly
    }

    var badges: [Badge] {
        Badge.allCases.filter { earnedBadges.contains($0.rawValue) }
    }

    // MARK: - Reset (parent-controlled)

    /// Wipes learning progress and gamification state but keeps the profile.
    /// Backs the parent view's "Reset progress" control and resets between
    /// playtest children on a shared device.
    func resetActiveProfileData() {
        unitProgress = [:]
        xp = 0
        currentStreak = 0
        longestStreak = 0
        lastPlayedDay = nil
        playedDays = []
        earnedBadges = []
    }

    /// Full teardown back to first-run onboarding. Used by the parent view's
    /// stronger "Remove child & data" control.
    func deleteEverything() {
        resetActiveProfileData()
        profiles = []
        activeProfileID = nil
    }

    // MARK: - Persistence helpers

    private func persist<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private static func load<T: Decodable>(forKey key: String, from defaults: UserDefaults) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    static func dayKey(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f.string(from: date)
    }
}
