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
///
/// **Identity is the question's prompt, not its position.** Keying on
/// `unitID#screenIndex` looked fine until a unit gained a screen: every index
/// after the insertion point then pointed at a *different* question, and a
/// child's review queue would quietly serve them the wrong item with the wrong
/// box history. The prompt is stable across content edits; the index is not.
struct ReviewItem: Codable, Equatable, Identifiable {
    /// "explorers.7#What does each yes-or-no answer do?"
    var id: String
    var unitID: String
    /// The exact quiz prompt, used to re-find the question after content moves.
    var prompt: String
    /// Where it was when enqueued — a hint for fast lookup, never the identity.
    var screenIndex: Int
    /// 1…5. Higher box = better known = longer gap before it returns.
    var box: Int = 1
    /// Day key ("yyyy-MM-dd") on or after which this is due.
    var dueDay: String

    /// Days to wait after a correct answer in each box.
    static let intervals: [Int: Int] = [1: 1, 2: 2, 3: 4, 4: 7, 5: 15]
    static let maxBox = 5

    static func id(unitID: String, prompt: String) -> String { "\(unitID)#\(prompt)" }

    func isDue(on day: String) -> Bool { dueDay <= day }

    /// A correct answer promotes the item and pushes it further out; a wrong
    /// one sends it back to box 1 to be seen again tomorrow. Mistakes cost
    /// nothing but another look — nothing here punishes the child.
    mutating func record(correct: Bool, today: Date) {
        box = correct ? min(box + 1, Self.maxBox) : 1
        let days = Self.intervals[box] ?? 1
        dueDay = ProgressStore.dayKey(today.addingTimeInterval(TimeInterval(days) * 86_400))
    }

    init(unitID: String, prompt: String, screenIndex: Int, dueDay: String) {
        self.id = Self.id(unitID: unitID, prompt: prompt)
        self.unitID = unitID
        self.prompt = prompt
        self.screenIndex = screenIndex
        self.dueDay = dueDay
    }

    /// Lenient, for the same reason `ProfileProgress`'s is: a synthesized
    /// decoder throws on any absent key, and the store loads with `try?`.
    /// Items persisted before `prompt` existed decode with an empty prompt,
    /// fail to resolve, and get dropped as stale rather than taking the
    /// child's whole history down with them.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        unitID      = try c.decodeIfPresent(String.self, forKey: .unitID) ?? ""
        prompt      = try c.decodeIfPresent(String.self, forKey: .prompt) ?? ""
        screenIndex = try c.decodeIfPresent(Int.self, forKey: .screenIndex) ?? 0
        box         = try c.decodeIfPresent(Int.self, forKey: .box) ?? 1
        dueDay      = try c.decodeIfPresent(String.self, forKey: .dueDay) ?? ""
        id          = try c.decodeIfPresent(String.self, forKey: .id)
            ?? Self.id(unitID: unitID, prompt: prompt)
    }
}
