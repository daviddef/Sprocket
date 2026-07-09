import SwiftUI

/// Drives one unit end to end: walk the screens in order (teach → do →
/// reflect), tally quiz correctness for stars, then hand off to the reward
/// screen which records completion, XP, streak, and any new badges.
///
/// The core loop from the build spec lives here: lesson → interactive →
/// reflect → reward → next unlocks.
struct LessonPlayerView: View {
    let unit: Unit
    var startIndex: Int = 0     // debug/QA only — jump straight to a screen

    @EnvironmentObject private var store: ProgressStore
    @Environment(\.dismiss) private var dismiss

    @State private var index = 0
    @State private var correct = 0
    @State private var earnedBadges: [Badge] = []
    @State private var finished = false

    private var screens: [LessonScreen] { unit.screens }
    private var quizTotal: Int {
        screens.reduce(0) { if case .quiz = $1 { return $0 + 1 }; return $0 }
    }

    var body: some View {
        ZStack {
            Theme.ground.ignoresSafeArea()

            if finished {
                RewardView(unit: unit,
                           stars: ProgressStore.stars(correct: correct, total: quizTotal),
                           badges: earnedBadges,
                           onDone: { dismiss() })
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                VStack(spacing: 0) {
                    topBar
                    screenContent
                        .id(index)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.28), value: index)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: finished)
        .onAppear { if startIndex > 0 { index = min(startIndex, screens.count - 1) } }
    }

    // MARK: Top bar

    private var topBar: some View {
        HStack(spacing: 14) {
            Button {
                Haptics.shared.tap(); SpeechService.shared.stop(); dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Theme.inkSoft)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Theme.ground3))
            }
            .accessibilityLabel("Close lesson")

            ProgressView(value: Double(index), total: Double(max(1, screens.count)))
                .tint(unit.tier.color)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    // MARK: Screens

    @ViewBuilder
    private var screenContent: some View {
        switch screens[index] {
        case .teach(let card):
            TeachCardView(card: card, tint: unit.tier.color, onNext: advance)
        case .quiz(let q):
            QuizView(question: q, tint: unit.tier.color,
                     onResult: { if $0 { correct += 1 } }, onNext: advance)
        case .reflect(let r):
            ReflectView(prompt: r, tint: unit.tier.color, onNext: advance)
        case .game(let game):
            gameView(for: game)
        }
    }

    @ViewBuilder
    private func gameView(for game: MiniGame) -> some View {
        switch game {
        case .sort(let g):
            SortGameView(game: g, tint: unit.tier.color, onNext: advance)
        case .decisionTree(let g):
            DecisionTreeView(game: g, tint: unit.tier.color, onNext: advance)
        case .promptImprover(let g):
            PromptImproverView(game: g, tint: unit.tier.color, onNext: advance)
        }
    }

    // MARK: Flow

    private func advance() {
        SpeechService.shared.stop()
        if index + 1 < screens.count {
            index += 1
        } else {
            earnedBadges = store.completeUnit(unit, correct: correct, total: quizTotal)
            Haptics.shared.win()
            finished = true
        }
    }
}
