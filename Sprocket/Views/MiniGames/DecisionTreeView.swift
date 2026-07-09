import SwiftUI

/// Walk a yes/no decision tree to an outcome — an embodied model of how a
/// machine "reasons" in steps. The child answers each question and watches
/// the path narrow to a result, then can replay or continue.
struct DecisionTreeView: View {
    let game: DecisionTreeGame
    var tint: Color = Theme.spark
    let onNext: () -> Void

    @State private var step: DecisionTreeGame.Step
    @State private var depth = 0

    init(game: DecisionTreeGame, tint: Color = Theme.spark, onNext: @escaping () -> Void) {
        self.game = game
        self.tint = tint
        self.onNext = onNext
        _step = State(initialValue: game.root)
    }

    var body: some View {
        VStack(spacing: 22) {
            VStack(spacing: 8) {
                Text(game.goal).font(.sprocket(22, .heavy)).multilineTextAlignment(.center)
                HStack(alignment: .top, spacing: 8) {
                    Text(game.intro).font(.sprocket(15)).foregroundStyle(Theme.inkSoft)
                        .multilineTextAlignment(.center)
                    SpeakerButton(text: game.intro)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)

            Spacer()

            switch step {
            case .ask(let question, _, _):
                askView(question)
                    .id(depth)
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .move(edge: .leading).combined(with: .opacity)))
            case .result(let text):
                resultView(text)
                    .transition(.scale.combined(with: .opacity))
            }

            Spacer()
        }
        .padding(.bottom, 20)
        .animation(.easeInOut(duration: 0.3), value: depth)
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: isResult)
    }

    private var isResult: Bool { if case .result = step { return true }; return false }

    private func askView(_ question: String) -> some View {
        VStack(spacing: 24) {
            ZStack {
                Circle().fill(tint.opacity(0.12)).frame(width: 120, height: 120)
                Image(systemName: "arrow.triangle.branch")
                    .font(.system(size: 46, weight: .bold)).foregroundStyle(tint)
            }
            Text(question)
                .font(.sprocket(24, .bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)

            HStack(spacing: 14) {
                answerButton("Yes", branch: true)
                answerButton("No", branch: false)
            }
            .padding(.horizontal, 24)
        }
    }

    private func answerButton(_ label: String, branch yes: Bool) -> some View {
        Button {
            Haptics.shared.tap()
            if case let .ask(_, yesStep, noStep) = step {
                withAnimation { step = yes ? yesStep : noStep; depth += 1 }
            }
        } label: {
            Text(label)
                .font(.sprocket(20, .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 64)
                .background(RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(yes ? tint : Theme.inkSoft))
        }
        .buttonStyle(.plain)
    }

    private func resultView(_ text: String) -> some View {
        VStack(spacing: 20) {
            Text(text)
                .font(.sprocket(30, .heavy))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            Text("The computer reached that by following your answers, one step at a time.")
                .font(.sprocket(14))
                .foregroundStyle(Theme.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(spacing: 10) {
                Button("Next") { Haptics.shared.tap(); onNext() }
                    .buttonStyle(.sprocket(tint))
                Button("Play Again") {
                    Haptics.shared.tap()
                    withAnimation { step = game.root; depth = 0 }
                }
                .buttonStyle(.sprocket(tint, filled: false))
            }
            .padding(.horizontal, 24)
            .padding(.top, 6)
        }
    }
}
