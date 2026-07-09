import Foundation

/// A single child using the app. An array from day one — v1's UI centers on
/// one active profile, but families with more than one kid (each on their
/// own tier) are a near-term feature, so the shape supports it now.
struct LearnerProfile: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var name: String
    var tier: Tier
    var createdAt: Date = Date()
}
