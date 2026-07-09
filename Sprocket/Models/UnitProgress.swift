import Foundation

/// Per-unit record of what a child has done. `stars` (0–3) reflect how many
/// quiz questions were answered correctly across the unit — a soft signal,
/// never a gate: a child always advances, mistakes are never punished.
struct UnitProgress: Codable, Equatable {
    var unitID: String
    var completed: Bool = false
    var stars: Int = 0
    var completedAt: Date?
}
