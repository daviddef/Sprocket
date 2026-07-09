import Foundation

/// Where the free/premium line sits. The first unit of every track is free so
/// a child (and a browsing parent) can actually try Sprocket before anyone
/// pays. Everything past it is "Sprocket Plus".
enum Gating {
    /// How many leading units of each track are free.
    static let freeUnitsPerTrack = 1

    /// A unit that requires a subscription (independent of whether it's also
    /// still sequentially locked behind an earlier unit).
    static func isPremium(_ unit: Unit) -> Bool {
        unit.order > freeUnitsPerTrack
    }
}
