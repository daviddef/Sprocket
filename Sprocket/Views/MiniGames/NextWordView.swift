import SwiftUI

/// "Guess the next word." The child predicts, then the model's probability
/// spread is revealed as bars. Being wrong is fine and common — the lesson is
/// that a language model picks the *most likely* continuation, which is not
/// the same thing as the *true* one.
struct NextWordView: View {
    let game: NextWordGame
    var tint: Color = Theme.spark
    let onNext: () -> Void

    @State private var roundIndex = 0
    @State private var picked: UUID?

    private var round: NextWordGame.Round { game.rounds[min(roundIndex, game.rounds.count - 1)] }
    private var revealed: Bool { picked != nil }
    private var isLastRound: Bool { roundIndex >= game.rounds.count - 1 }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                header

                sentence

                VStack(spacing: 10) {
                    ForEach(sortedOptions) { option in
                        optionRow(option)
                    }
                }
                .padding(.horizontal, 20)

                if revealed {
                    insightCard
                        .padding(.horizontal, 20)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))

                    Button(isLastRound ? "Next" : "Next Word") {
                        Haptics.shared.tap()
                        if isLastRound { onNext() }
                        else { roundIndex += 1; picked = nil }
                    }
                    .buttonStyle(.sprocket(tint))
                    .padding(.horizontal, 20)
                }
                Color.clear.frame(height: 12)
            }
        }
        .animation(.easeInOut(duration: 0.28), value: picked)
        .animation(.easeInOut(duration: 0.28), value: roundIndex)
        #if DEBUG
        // QA: SPROCKET_DEBUG_AUTOPICK=1 pre-answers so the revealed
        // probability bars can be screenshotted without tapping.
        .onAppear {
            if ProcessInfo.processInfo.environment["SPROCKET_DEBUG_AUTOPICK"] == "1" {
                picked = round.options.first?.id
            }
        }
        #endif
    }

    /// Before the reveal, keep the authored order so the likeliest word isn't
    /// always sitting at the top giving the answer away.
    private var sortedOptions: [NextWordGame.Round.Option] {
        revealed ? round.options.sorted { $0.probability > $1.probability } : round.options
    }

    private var header: some View {
        VStack(spacing: 8) {
            Label("Guess the Next Word", systemImage: "text.word.spacing")
                .font(.sprocket(21, .heavy)).foregroundStyle(Theme.ink)
            HStack(alignment: .top, spacing: 8) {
                Text(game.intro)
                    .font(.sprocket(14)).foregroundStyle(Theme.inkSoft)
                    .multilineTextAlignment(.center)
                SpeakerButton(text: game.intro)
            }
            ProgressView(value: Double(roundIndex), total: Double(game.rounds.count))
                .tint(tint)
                .padding(.top, 2)
        }
        .padding(.horizontal, 22)
        .padding(.top, 8)
    }

    private var sentence: some View {
        Text(round.context)
            .font(.sprocket(20, .bold))
            .multilineTextAlignment(.center)
            .padding(18)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Theme.ground2))
            .padding(.horizontal, 20)
    }

    private func optionRow(_ option: NextWordGame.Round.Option) -> some View {
        let isTop = option.id == round.likeliest?.id
        let isPicked = option.id == picked
        return Button {
            guard picked == nil else { return }
            picked = option.id
            isTop ? Haptics.shared.win() : Haptics.shared.tryAgain()
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(option.word)
                        .font(.sprocket(17, .bold)).foregroundStyle(Theme.ink)
                    if revealed && isTop {
                        Text("MODEL'S PICK")
                            .font(.sprocket(9, .heavy)).foregroundStyle(.white)
                            .padding(.horizontal, 7).padding(.vertical, 3)
                            .background(Capsule().fill(tint))
                    }
                    Spacer()
                    if revealed {
                        Text("\(Int((option.probability * 100).rounded()))%")
                            .font(.sprocket(15, .heavy)).monospacedDigit()
                            .foregroundStyle(isTop ? tint : Theme.inkFaint)
                    } else if isPicked {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(tint)
                    }
                }

                if revealed {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Theme.ground3).frame(height: 8)
                            Capsule()
                                .fill(isTop ? tint : Theme.inkFaint.opacity(0.45))
                                .frame(width: max(6, geo.size.width * option.probability), height: 8)
                        }
                    }
                    .frame(height: 8)
                }
            }
            .padding(14)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Theme.ground2)
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(borderColor(isTop: isTop, isPicked: isPicked),
                                          lineWidth: (revealed && isTop) || isPicked ? 2.5 : 1)
                    }
            }
        }
        .buttonStyle(.plain)
        .disabled(revealed)
    }

    private func borderColor(isTop: Bool, isPicked: Bool) -> Color {
        if revealed && isTop { return tint }
        if isPicked { return Theme.gentle }
        return Theme.line
    }

    private var insightCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: pickedIsTop ? "sparkles" : "lightbulb.fill")
                .foregroundStyle(pickedIsTop ? Theme.correct : Theme.gentle)
            Text(round.insight)
                .font(.sprocket(14)).foregroundStyle(Theme.ink)
            Spacer(minLength: 0)
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill((pickedIsTop ? Theme.correctBG : Theme.gentleBG).opacity(0.6))
        }
    }

    private var pickedIsTop: Bool { picked != nil && picked == round.likeliest?.id }
}
