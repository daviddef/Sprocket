import SwiftUI

/// A check-for-understanding. One pick, then the answer is revealed with a
/// gentle explanation — a wrong choice is never buzzed or blocked; the child
/// sees why and moves on. First-pick correctness is reported once, for stars.
///
/// When narration is on (the default for pre-readers in Sprouts) the whole
/// question is operable by ear: each answer gets its own speaker, and the
/// explanation is read aloud on reveal. A five-year-old must never be blocked
/// from answering because they can't yet read the options.
struct QuizView: View {
    let question: QuizQuestion
    var tint: Color = Theme.spark
    let onResult: (Bool) -> Void
    let onNext: () -> Void

    @EnvironmentObject private var store: ProgressStore
    @State private var picked: Int?

    private var revealed: Bool { picked != nil }
    private var narrating: Bool { store.narrationEnabled }

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 8)

            HStack(alignment: .top, spacing: 10) {
                Text(question.prompt)
                    .sprocketFont(23, .bold)
                    .multilineTextAlignment(.leading)
                SpeakerButton(text: question.narration ?? question.prompt,
                              autoNarrate: true)
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                ForEach(Array(question.options.enumerated()), id: \.offset) { i, option in
                    optionButton(i, option)
                }
            }
            .padding(.horizontal, 24)

            if revealed {
                explanationCard
                    .padding(.horizontal, 24)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            Spacer()

            if revealed {
                Button("Next") { Haptics.shared.tap(); onNext() }
                    .buttonStyle(.sprocket(tint))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: picked)
        .onChange(of: picked) { _, newValue in
            // Pre-readers can't read the explanation, which is where the actual
            // teaching happens on a wrong answer. Read it to them.
            guard narrating, newValue != nil else { return }
            SpeechService.shared.speak(question.explanation)
        }
    }

    /// The tap target and its speaker are siblings, not nested buttons — a
    /// Button inside a Button swallows the inner tap.
    @ViewBuilder
    private func optionButton(_ i: Int, _ option: String) -> some View {
        HStack(spacing: 8) {
            optionTapTarget(i, option)
            if narrating && !revealed {
                SpeakerButton(text: option)
            }
        }
    }

    private func optionTapTarget(_ i: Int, _ option: String) -> some View {
        Button {
            guard picked == nil else { return }
            picked = i
            let right = i == question.correctIndex
            right ? Haptics.shared.win() : Haptics.shared.tryAgain()
            onResult(right)
        } label: {
            HStack(spacing: 12) {
                Text(option)
                    .sprocketFont(17, .semibold)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(Theme.ink)
                Spacer(minLength: 8)
                if revealed { statusIcon(for: i) }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(background(for: i))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(border(for: i), lineWidth: 2)
                    }
            }
        }
        .buttonStyle(.plain)
        .disabled(revealed)
    }

    @ViewBuilder
    private func statusIcon(for i: Int) -> some View {
        if i == question.correctIndex {
            Image(systemName: "checkmark.circle.fill").foregroundStyle(Theme.correct)
        } else if i == picked {
            Image(systemName: "arrow.uturn.left.circle.fill").foregroundStyle(Theme.gentle)
        }
    }

    private func background(for i: Int) -> Color {
        guard revealed else { return Theme.ground2 }
        if i == question.correctIndex { return Theme.correctBG }
        if i == picked { return Theme.gentleBG }
        return Theme.ground2
    }
    private func border(for i: Int) -> Color {
        guard revealed else { return Theme.line }
        if i == question.correctIndex { return Theme.correct }
        if i == picked { return Theme.gentle }
        return Theme.line
    }

    private var explanationCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: picked == question.correctIndex ? "sparkles" : "lightbulb.fill")
                .foregroundStyle(picked == question.correctIndex ? Theme.correct : Theme.gentle)
            Text(question.explanation)
                .sprocketFont(15)
                .foregroundStyle(Theme.ink)
            Spacer(minLength: 0)
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill((picked == question.correctIndex ? Theme.correctBG : Theme.gentleBG).opacity(0.6))
        }
    }
}
