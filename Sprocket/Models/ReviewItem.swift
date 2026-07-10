import Foundation

/// One question scheduled for retrieval practice.
///
/// Finishing a lesson once is not learning it — the testing and spacing effects
/// are among the most robust findings in cognitive psychology, and the app had
/// neither: a completed unit was never seen again. Each quiz question a child
/// answers becomes a `ReviewItem` and comes back on a widening schedule.
///
/// A Leitner box, deliberately, rather than full SM-2: five boxes are legible
/// to a parent, cheap to compute, and don't need an ease factor a 7-year-old's
/// answer data can't support.
struct ReviewItem: Codable, Equatable, Identifiable {
    /// "explorers.7#3" — unit id and the index of the quiz screen within it.
    var id: String
    var unitID: String
    var screenIndex: Int
    /// 1…5. Higher box = better known = longer gap before it returns.
    var box: Int = 1
    /// Day key ("yyyy-MM-dd") on or after which this is due.
    var dueDay: String

    /// Days to wait after a correct answer in each box.
    static let intervals: [Int: Int] = [1: 1, 2: 2, 3: 4, 4: 7, 5: 15]
    static let maxBox = 5

    static func id(unitID: String, screenIndex: Int) -> String {
        "\(unitID)#\(screenIndex)"
    }

    func isDue(on day: String) -> Bool { dueDay <= day }

    /// A correct answer promotes the item and pushes it further out; a wrong
    /// one sends it back to box 1 to be seen again tomorrow. Mistakes cost
    /// nothing but another look — nothing here punishes the child.
    mutating func record(correct: Bool, today: Date) {
        box = correct ? min(box + 1, Self.maxBox) : 1
        let days = Self.intervals[box] ?? 1
        dueDay = ProgressStore.dayKey(today.addingTimeInterval(TimeInterval(days) * 86_400))
    }
}
