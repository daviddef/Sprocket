import Foundation

/// Everything one child accumulates: their unit progress, XP, streak, badges,
/// their review queue, and their own narration preference (a 6-year-old wants
/// read-aloud on; their 14-year-old sibling does not).
///
/// One of these per profile. Splitting it out of `ProgressStore` is what makes
/// the "one subscription, every child" family promise actually true — before
/// this, siblings shared a single flat progress record.
///
/// **The decoder is hand-written on purpose.** Swift's synthesized `Codable`
/// calls `decode(_:forKey:)` for every property — *including ones with default
/// values* — and throws `keyNotFound` when a key is absent. Since the store
/// loads with `try?`, adding a single new field to this struct would turn every
/// already-saved record into `nil` and wipe a child's entire history on update.
/// Decoding every field with `decodeIfPresent` makes the type tolerant of both
/// older and newer payloads. Do not replace this with the synthesized version.
struct ProfileProgress: Codable, Equatable {
    var unitProgress: [String: UnitProgress] = [:]
    var xp: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastPlayedDay: String?
    var playedDays: Set<String> = []
    var earnedBadges: Set<String> = []
    var narrationEnabled: Bool = false
    /// Retrieval-practice queue, keyed by `ReviewItem.id`.
    var reviewItems: [String: ReviewItem] = [:]

    init() {}

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        unitProgress     = try c.decodeIfPresent([String: UnitProgress].self, forKey: .unitProgress) ?? [:]
        xp               = try c.decodeIfPresent(Int.self, forKey: .xp) ?? 0
        currentStreak    = try c.decodeIfPresent(Int.self, forKey: .currentStreak) ?? 0
        longestStreak    = try c.decodeIfPresent(Int.self, forKey: .longestStreak) ?? 0
        lastPlayedDay    = try c.decodeIfPresent(String.self, forKey: .lastPlayedDay)
        playedDays       = try c.decodeIfPresent(Set<String>.self, forKey: .playedDays) ?? []
        earnedBadges     = try c.decodeIfPresent(Set<String>.self, forKey: .earnedBadges) ?? []
        narrationEnabled = try c.decodeIfPresent(Bool.self, forKey: .narrationEnabled) ?? false
        reviewItems      = try c.decodeIfPresent([String: ReviewItem].self, forKey: .reviewItems) ?? [:]
    }
}
