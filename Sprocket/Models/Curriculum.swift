import SwiftUI

// MARK: - Unit (a node on the skill map)

/// One node on the map = one Unit = one short lesson. A unit belongs to a
/// tier and a Big Idea, and is an ordered sequence of screens the lesson
/// player walks through: teach → do → reflect → (reward is added by the
/// player itself on completion).
struct Unit: Identifiable {
    let id: String            // e.g. "sprouts.1"
    let tier: Tier
    let bigIdea: BigIdea
    let order: Int            // 1-based position within the track
    let title: String
    let subtitle: String
    let symbol: String
    let screens: [LessonScreen]

    /// Rough "minutes" label for the map — kept in the 3–6 range so a unit
    /// fits a car ride or a bedtime slot.
    var minutes: Int { min(6, max(3, Int((Double(screens.count) * 1.2).rounded()))) }
}

// MARK: - Screens

/// The four kinds of thing a lesson can put in front of a child. The player
/// advances through them by index, so screens don't need stable identity.
enum LessonScreen {
    case teach(TeachCard)
    case quiz(QuizQuestion)
    case game(MiniGame)
    case reflect(ReflectPrompt)
}

/// A "here's an idea" card: one thought, plainly told, with a symbol and
/// optional narration for pre-readers.
struct TeachCard {
    let title: String
    let body: String
    let symbol: String
    var narration: String? = nil    // falls back to "title. body" if nil
}

/// A check-for-understanding. There's a right answer, but a wrong pick is
/// met with a gentle explanation, never a buzzer — then the child moves on.
struct QuizQuestion {
    let prompt: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
    var narration: String? = nil
}

/// An open prompt with no wrong answer — a moment to pause and choose or
/// feel. Used for the "reflect" beat and for softer social/ethical topics.
struct ReflectPrompt {
    let prompt: String
    let options: [String]
    var narration: String? = nil
}

// MARK: - Mini-games

/// Interactive beats. Each case carries its own fully-authored config so the
/// content stays data-driven and the game views stay dumb renderers.
enum MiniGame {
    case sort(SortGame)
    case decisionTree(DecisionTreeGame)
    case promptImprover(PromptImproverGame)

    var title: String {
        switch self {
        case .sort(let g):    return g.title
        case .decisionTree:   return "Follow the Map"
        case .promptImprover: return "Better Asking"
        }
    }
}

/// A two-bin sorter — the workhorse interactive. Reused across tiers with
/// different bins: "Smart Computer / Just a Thing" (what is AI?), or "Cat /
/// Dog" to feel how a model is trained by labeled examples.
struct SortGame {
    let title: String
    let intro: String
    let binA: Bin
    let binB: Bin
    let items: [Item]

    struct Bin {
        let label: String
        let symbol: String
        let color: Color
    }

    struct Item: Identifiable {
        let id = UUID()
        let label: String
        let symbol: String
        let inA: Bool          // true → belongs in binA
    }
}

/// Walk a yes/no decision tree to a result — a first, embodied model of how
/// a machine "reasons" in steps. Indirect enum so the tree nests cleanly.
struct DecisionTreeGame {
    let intro: String
    let goal: String
    let root: Step

    indirect enum Step {
        case ask(question: String, yes: Step, no: Step)
        case result(String)
    }
}

/// Compare ways of asking an AI for the same thing and pick the clearest.
/// Each option shows the (simulated) result it would produce, so the lesson
/// of "clear prompts get better answers" is felt, not just told.
struct PromptImproverGame {
    let intro: String
    let task: String
    let options: [Option]

    struct Option: Identifiable {
        let id = UUID()
        let text: String
        let isBest: Bool
        let result: String
    }
}

// MARK: - Curriculum access

/// The whole course. Content itself lives in `Curriculum+Sprouts/Explorers/
/// Builders` extensions (authored in Swift, like Fernby's ContentBank), so
/// this file stays a thin index.
enum Curriculum {
    static func track(for tier: Tier) -> [Unit] {
        switch tier {
        case .sprouts:   return sprouts
        case .explorers: return explorers
        case .builders:  return builders
        }
    }

    static func unit(id: String) -> Unit? {
        Tier.allCases
            .flatMap { track(for: $0) }
            .first { $0.id == id }
    }

    /// Units of a tier that share a Big Idea — used to award the "Idea
    /// Master" badge and to group the parent view.
    static func units(in tier: Tier, idea: BigIdea) -> [Unit] {
        track(for: tier).filter { $0.bigIdea == idea }
    }
}
