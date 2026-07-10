import SwiftUI

/// Achievement badges — the "achievement" leg of the confirmed Duolingo
/// pattern (challenge · reward · levels · achievement). Extrinsic-but-
/// progression mechanics only; no social leaderboards for under-13s, by design
/// and by compliance.
///
/// Deliberately **not** the engine of learning. Meta-analysis found badges and
/// leaderboards produce no significant effect on grades even when they control
/// 100% of the grade, and gamification's effect on competence is minimal
/// (g≈0.28). They stay as light scaffolding — and, per the same research, the
/// ones previously earned by mere attendance now require *demonstrated
/// mastery*: stars earned, or answers genuinely recalled days later.
enum Badge: String, Codable, CaseIterable, Identifiable {
    case firstStep          // finish your first unit — a welcome, not a claim
    case threeInARow        // 3-day streak
    case weekStreak         // 7-day streak
    case curiousMind        // 5 units finished with 2+ stars (mastery, not attendance)
    case wellRemembered     // 25 review questions recalled correctly
    case ideaMaster         // every unit of one Big Idea, all at 3 stars
    case graduate           // finish an entire tier

    var id: String { rawValue }

    var title: String {
        switch self {
        case .firstStep:   return "First Step"
        case .threeInARow: return "Three in a Row"
        case .weekStreak:  return "Week Streak"
        case .curiousMind: return "Curious Mind"
        case .wellRemembered: return "Well Remembered"
        case .ideaMaster:  return "Idea Master"
        case .graduate:    return "Graduate"
        }
    }

    var blurb: String {
        switch self {
        case .firstStep:   return "Finished your very first lesson."
        case .threeInARow: return "Learned 3 days in a row."
        case .weekStreak:  return "Learned 7 days in a row!"
        case .curiousMind: return "Finished 5 lessons really well."
        case .wellRemembered: return "Remembered 25 answers later on."
        case .ideaMaster:  return "Got full stars on a whole Big Idea."
        case .graduate:    return "Finished a whole track. Wow!"
        }
    }

    var symbol: String {
        switch self {
        case .firstStep:   return "figure.walk"
        case .threeInARow: return "flame.fill"
        case .weekStreak:  return "flame.circle.fill"
        case .curiousMind: return "sparkles"
        case .wellRemembered: return "brain.head.profile"
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
        case .wellRemembered: return Color(hex: 0x8A5BC4)
        case .ideaMaster:  return Theme.builders
        case .graduate:    return Theme.correct
        }
    }
}
