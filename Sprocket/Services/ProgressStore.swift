import Foundation
import SwiftUI

/// Single source of truth for everything that survives between launches:
/// the child profiles and, **per child**, their unit progress and gamification
/// state (XP, streak, badges, days played). Same shape as Fernby's
/// ProgressStore — UserDefaults + Codable, namespaced keys, auto-persist on
/// `didSet` — so the two apps stay mentally interchangeable.
///
/// Progress is keyed by profile id. The `xp` / `currentStreak` / `unitProgress`
/// accessors read and write the *active* child's record, so call sites read
/// exactly as they did when this was a single-profile store.
@MainActor
final class ProgressStore: ObservableObject {
    static let shared = ProgressStore()

    private let defaults = UserDefaults.standard

    private enum Key {
        static let profiles          = "sprocket.profiles"
        static let activeProfile     = "sprocket.activeProfileID"
        static let progressByProfile = "sprocket.progressByProfile"

        // Legacy single-profile keys, migrated once then removed.
        static let legacy: [String] = [
            "sprocket.unitProgress", "sprocket.xp", "sprocket.currentStreak",
            "sprocket.longestStreak", "sprocket.lastPlayedDay", "sprocket.playedDays",
            "sprocket.badges", "sprocket.narrationEnabled",
        ]
    }

    /// XP awarded per finished unit. Small numbers, frequent wins.
    static let xpPerUnit = 20
    /// Retrieval practice is the learning engine, so it pays too — modestly.
    static let xpPerReview = 5
    /// A review session stays short enough to finish in one sitting.
    static let maxReviewsPerSession = 8
    /// Enough for a large family without the picker becoming a scroll.
    static let maxChildren = 6

    @Published var profiles: [LearnerProfile] {
        didSet { persist(profiles, forKey: Key.profiles) }
    }
    @Published var activeProfileID: UUID? {
        didSet { defaults.set(activeProfileID?.uuidString, forKey: Key.activeProfile) }
    }
    /// Keyed by `LearnerProfile.id.uuidString`.
    @Published private var progressByProfile: [String: ProfileProgress] {
        didSet { persist(progressByProfile, forKey: Key.progressByProfile) }
    }

    private init() {
        profiles          = Self.load(forKey: Key.profiles, from: defaults) ?? []
        activeProfileID   = UUID(uuidString: defaults.string(forKey: Key.activeProfile) ?? "")
        progressByProfile = Self.load(forKey: Key.progressByProfile, from: defaults) ?? [:]
        migrateLegacyIfNeeded()
    }

    /// One-time lift of the old flat, single-profile record into the active
    /// child's slot. Runs only when there's legacy data and no per-profile data
    /// yet, then clears the old keys so it can never run twice.
    private func migrateLegacyIfNeeded() {
        guard progressByProfile.isEmpty,
              let activeID = activeProfileID,
              defaults.object(forKey: "sprocket.xp") != nil
                || defaults.data(forKey: "sprocket.unitProgress") != nil
        else { return }

        var p = ProfileProgress()
        p.unitProgress    = Self.load(forKey: "sprocket.unitProgress", from: defaults) ?? [:]
        p.xp              = defaults.integer(forKey: "sprocket.xp")
        p.currentStreak   = defaults.integer(forKey: "sprocket.currentStreak")
        p.longestStreak   = defaults.integer(forKey: "sprocket.longestStreak")
        p.lastPlayedDay   = defaults.string(forKey: "sprocket.lastPlayedDay")
        p.playedDays      = Self.load(forKey: "sprocket.playedDays", from: defaults) ?? []
        p.earnedBadges    = Self.load(forKey: "sprocket.badges", from: defaults) ?? []
        p.narrationEnabled = defaults.object(forKey: "sprocket.narrationEnabled") as? Bool ?? false

        progressByProfile[activeID.uuidString] = p
        Key.legacy.forEach { defaults.removeObject(forKey: $0) }
    }

    // MARK: - Active child's record

    /// Reads fall back to an empty record (only reachable pre-onboarding);
    /// writes no-op when there's no active child.
    private var current: ProfileProgress {
        get { activeProfileID.flatMap { progressByProfile[$0.uuidString] } ?? ProfileProgress() }
        set { if let id = activeProfileID { progressByProfile[id.uuidString] = newValue } }
    }

    var unitProgress: [String: UnitProgress] {
        get { current.unitProgress } set { current.unitProgress = newValue }
    }
    var xp: Int { get { current.xp } set { current.xp = newValue } }
    var currentStreak: Int { get { current.currentStreak } set { current.currentStreak = newValue } }
    var longestStreak: Int { get { current.longestStreak } set { current.longestStreak = newValue } }
    var lastPlayedDay: String? { get { current.lastPlayedDay } set { current.lastPlayedDay = newValue } }
    var playedDays: Set<String> { get { current.playedDays } set { current.playedDays = newValue } }
    var earnedBadges: Set<String> { get { current.earnedBadges } set { current.earnedBadges = newValue } }
    var narrationEnabled: Bool { get { current.narrationEnabled } set { current.narrationEnabled = newValue } }
    var reviewItems: [String: ReviewItem] { get { current.reviewItems } set { current.reviewItems = newValue } }

    // MARK: - Retrieval practice
    //
    // Finishing a lesson isn't learning it. Low-stakes retrieval beats
    // re-reading with medium effect sizes in real classrooms, so every quiz a
    // child answers is enqueued and comes back on a widening schedule.

    /// Questions due today or overdue, oldest first, capped to a session.
    var dueReviews: [ReviewItem] {
        let today = Self.dayKey(Date())
        return reviewItems.values
            .filter { $0.isDue(on: today) }
            .sorted { $0.dueDay < $1.dueDay }
            .prefix(Self.maxReviewsPerSession)
            .map { $0 }
    }

    var dueReviewCount: Int {
        let today = Self.dayKey(Date())
        return reviewItems.values.filter { $0.isDue(on: today) }.count
    }

    /// Called when a unit is completed: every quiz screen in it joins the queue,
    /// first due tomorrow. Never re-enqueues one already being tracked, so a
    /// replayed lesson doesn't reset a child's hard-won box position.
    private func enqueueReviews(for unit: Unit) {
        let tomorrow = Self.dayKey(Date().addingTimeInterval(86_400))
        for (index, screen) in unit.screens.enumerated() {
            guard case .quiz = screen else { continue }
            let id = ReviewItem.id(unitID: unit.id, screenIndex: index)
            guard reviewItems[id] == nil else { continue }
            reviewItems[id] = ReviewItem(id: id, unitID: unit.id, screenIndex: index, dueDay: tomorrow)
        }
    }

    func recordReview(_ item: ReviewItem, correct: Bool) {
        var updated = item
        updated.record(correct: correct, today: Date())
        reviewItems[updated.id] = updated
        if correct { xp += Self.xpPerReview }
    }

    /// A review session counts as showing up today, same as a lesson.
    func recordReviewSessionFinished() {
        recordPlayToday()
    }

    // MARK: - Profiles

    var activeProfile: LearnerProfile? {
        profiles.first { $0.id == activeProfileID }
    }

    /// The tier the app is currently teaching. Falls back to Sprouts only if
    /// somehow called before onboarding (never shown to a user in that state).
    var tier: Tier { activeProfile?.tier ?? .sprouts }

    var track: [Unit] { Curriculum.track(for: tier) }

    var canAddChild: Bool { profiles.count < Self.maxChildren }

    @discardableResult
    func createProfile(name: String, tier: Tier) -> LearnerProfile {
        let profile = LearnerProfile(name: name.isEmpty ? tier.name : name, tier: tier)
        profiles.append(profile)
        var fresh = ProfileProgress()
        fresh.narrationEnabled = tier.narrationOnByDefault
        progressByProfile[profile.id.uuidString] = fresh
        activeProfileID = profile.id
        return profile
    }

    func switchTo(_ id: UUID) {
        guard profiles.contains(where: { $0.id == id }) else { return }
        activeProfileID = id
    }

    /// Removes a child and everything they've done. If they were the active
    /// child, hands the app to a sibling — or back to onboarding if none.
    func removeProfile(_ id: UUID) {
        profiles.removeAll { $0.id == id }
        progressByProfile.removeValue(forKey: id.uuidString)
        if activeProfileID == id { activeProfileID = profiles.first?.id }
    }

    /// Moves a child to a different age track and resets their narration
    /// default to suit it.
    func setTier(_ tier: Tier, for id: UUID) {
        guard let idx = profiles.firstIndex(where: { $0.id == id }) else { return }
        profiles[idx].tier = tier
        var p = progressByProfile[id.uuidString] ?? ProfileProgress()
        p.narrationEnabled = tier.narrationOnByDefault
        progressByProfile[id.uuidString] = p
    }

    /// Progress summary for any child, not just the active one — the parent
    /// view lists every child at a glance.
    func completedCount(for profile: LearnerProfile) -> Int {
        let p = progressByProfile[profile.id.uuidString] ?? ProfileProgress()
        return Curriculum.track(for: profile.tier)
            .filter { p.unitProgress[$0.id]?.completed == true }.count
    }

    func xp(for profile: LearnerProfile) -> Int {
        progressByProfile[profile.id.uuidString]?.xp ?? 0
    }

    // MARK: - Unit progress & unlocking

    func progress(for unitID: String) -> UnitProgress {
        unitProgress[unitID] ?? UnitProgress(unitID: unitID)
    }

    func isCompleted(_ unitID: String) -> Bool {
        progress(for: unitID).completed
    }

    /// A unit is open if it's the first in the track or the one before it is
    /// done. Strictly linear — a clear single path up the map.
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

    /// Called by the lesson player when a unit is finished. Records stars & XP,
    /// advances the daily streak, and evaluates any newly-earned badges.
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

        enqueueReviews(for: unit)
        recordPlayToday()
        return awardBadges(justFinished: unit)
    }

    static func stars(correct: Int, total: Int) -> Int {
        guard total > 0 else { return 3 }
        let ratio = Double(correct) / Double(total)
        switch ratio {
        case 1.0:    return 3
        case 0.6...: return 2
        default:     return 1   // finishing always earns at least one
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

    /// Wipes the active child's learning progress but keeps the child.
    func resetActiveProfileData() {
        guard let id = activeProfileID else { return }
        var fresh = ProfileProgress()
        fresh.narrationEnabled = tier.narrationOnByDefault
        progressByProfile[id.uuidString] = fresh
    }

    /// Full teardown back to first-run onboarding: every child, every record.
    func deleteEverything() {
        progressByProfile = [:]
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

    /// `nonisolated` so value types like `ReviewItem` can compute their own due
    /// dates without hopping to the main actor.
    nonisolated static func dayKey(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f.string(from: date)
    }
}
