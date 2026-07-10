import Foundation

/// Everything one child accumulates: their unit progress, XP, streak, badges,
/// and their own narration preference (a 6-year-old wants read-aloud on; their
/// 14-year-old sibling does not).
///
/// One of these per profile. Splitting it out of `ProgressStore` is what makes
/// the "one subscription, every child" family promise actually true — before
/// this, siblings shared a single flat progress record.
struct ProfileProgress: Codable, Equatable {
    var unitProgress: [String: UnitProgress] = [:]
    var xp: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastPlayedDay: String?
    var playedDays: Set<String> = []
    var earnedBadges: Set<String> = []
    var narrationEnabled: Bool = false
}
