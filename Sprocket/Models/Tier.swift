import SwiftUI

/// The three age tracks. Same curriculum spine (the Five Big Ideas), taught
/// at rising depth — a spiral, not three unrelated products. The tier a
/// child is on is chosen once, by a grown-up, during onboarding.
enum Tier: String, Codable, CaseIterable, Identifiable {
    case sprouts     // 5–8   — play-first, pre-reader friendly
    case explorers   // 9–12  — concept + mini-project
    case builders    // 13–17 — how it works, responsible use

    var id: String { rawValue }

    var name: String {
        switch self {
        case .sprouts:   return "Sprouts"
        case .explorers: return "Explorers"
        case .builders:  return "Builders"
        }
    }

    var ageRange: String {
        switch self {
        case .sprouts:   return "Ages 5–8"
        case .explorers: return "Ages 9–12"
        case .builders:  return "Ages 13–17"
        }
    }

    var tagline: String {
        switch self {
        case .sprouts:   return "Play, sort, and meet AI"
        case .explorers: return "Train it, break it, fix it"
        case .builders:  return "How it works — and how to use it well"
        }
    }

    var color: Color {
        switch self {
        case .sprouts:   return Theme.sprouts
        case .explorers: return Theme.explorers
        case .builders:  return Theme.builders
        }
    }

    var softColor: Color {
        switch self {
        case .sprouts:   return Theme.sproutsBG
        case .explorers: return Theme.explorersBG
        case .builders:  return Theme.buildersBG
        }
    }

    var symbol: String {
        switch self {
        case .sprouts:   return "leaf.fill"
        case .explorers: return "map.fill"
        case .builders:  return "hammer.fill"
        }
    }

    /// Pre-readers in the youngest tier get audio narration on by default;
    /// older tiers can read, so it's off unless a parent turns it on.
    var narrationOnByDefault: Bool { self == .sprouts }
}
