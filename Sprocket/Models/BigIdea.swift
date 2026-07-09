import SwiftUI

/// AI4K12's "Five Big Ideas" — the national K-12 framework this curriculum
/// is built on. Every unit belongs to one of these, and every tier revisits
/// all five, so the map a child learns in Sprouts still holds in Builders.
enum BigIdea: String, Codable, CaseIterable, Identifiable {
    case perception     // 1 — computers sense the world
    case reasoning      // 2 — representation & reasoning
    case learning       // 3 — machines learn from data
    case interaction    // 4 — natural interaction (this is where prompts live)
    case impact         // 5 — societal impact (ethics, safety, dangers)

    var id: String { rawValue }

    var number: Int {
        switch self {
        case .perception:  return 1
        case .reasoning:   return 2
        case .learning:    return 3
        case .interaction: return 4
        case .impact:      return 5
        }
    }

    /// The formal AI4K12 name (shown to Builders and in the parent view).
    var title: String {
        switch self {
        case .perception:  return "Perception"
        case .reasoning:   return "Representation & Reasoning"
        case .learning:    return "Learning"
        case .interaction: return "Natural Interaction"
        case .impact:      return "Societal Impact"
        }
    }

    /// The kid-facing name (shown to Sprouts and Explorers).
    var kidTitle: String {
        switch self {
        case .perception:  return "Computers Can Sense"
        case .reasoning:   return "Thinking in Steps"
        case .learning:    return "Learning From Examples"
        case .interaction: return "Talking With AI"
        case .impact:      return "Good, Bad & Being Fair"
        }
    }

    var symbol: String {
        switch self {
        case .perception:  return "eye.fill"
        case .reasoning:   return "arrow.triangle.branch"
        case .learning:    return "brain.head.profile"
        case .interaction: return "bubble.left.and.bubble.right.fill"
        case .impact:      return "scale.3d"
        }
    }

    var color: Color {
        switch self {
        case .perception:  return Color(hex: 0x3B8FD4)
        case .reasoning:   return Color(hex: 0x8A5BC4)
        case .learning:    return Color(hex: 0x1F9A8A)
        case .interaction: return Color(hex: 0xE07A2A)
        case .impact:      return Color(hex: 0xC4506B)
        }
    }
}
