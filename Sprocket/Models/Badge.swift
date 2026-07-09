import SwiftUI

/// Achievement badges — the "achievement ranking" leg of the confirmed
/// Duolingo gamification pattern (challenge · reward · levels · achievement).
/// Extrinsic-but-progression mechanics only; no social leaderboards for
/// under-13s, by design and by compliance.
enum Badge: String, Codable, CaseIterable, Identifiable {
    case firstStep          // finish your first unit
    case threeInARow        // 3-day streak
    case weekStreak         // 7-day streak
    case curiousMind        // finish 5 units
    case ideaMaster         // finish every unit of one Big Idea in your tier
    case graduate           // finish an entire tier

    var id: String { rawValue }

    var title: String {
        switch self {
        case .firstStep:   return "First Step"
        case .threeInARow: return "Three in a Row"
        case .weekStreak:  return "Week Streak"
        case .curiousMind: return "Curious Mind"
        case .ideaMaster:  return "Idea Master"
        case .graduate:    return "Graduate"
        }
    }

    var blurb: String {
        switch self {
        case .firstStep:   return "Finished your very first lesson."
        case .threeInARow: return "Learned 3 days in a row."
        case .weekStreak:  return "Learned 7 days in a row!"
        case .curiousMind: return "Finished 5 lessons."
        case .ideaMaster:  return "Mastered a whole Big Idea."
        case .graduate:    return "Finished a whole track. Wow!"
        }
    }

    var symbol: String {
        switch self {
        case .firstStep:   return "figure.walk"
        case .threeInARow: return "flame.fill"
        case .weekStreak:  return "flame.circle.fill"
        case .curiousMind: return "sparkles"
        case .ideaMaster:  return "star.circle.fill"
        case .graduate:    return "graduationcap.fill"
        }
    }

    var color: Color {
        switch self {
        case .firstStep:   return Theme.explorers
        case .threeInARow: return Theme.spark
        case .weekStreak:  return Theme.sparkDeep
        case .curiousMind: return Theme.sprouts
        case .ideaMaster:  return Theme.builders
        case .graduate:    return Theme.correct
        }
    }
}
