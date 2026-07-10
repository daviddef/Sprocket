import SwiftUI

/// Compare ways of asking an AI for the same thing. Tapping a prompt reveals
/// the (simulated) result it would produce, so "clear prompts get better
/// answers" is felt, not just told. The best prompt is celebrated; weaker
/// ones show why they fall short — kindly, and the child can still continue.
struct PromptImproverView: View {
    let game: PromptImproverGame
    var tint: Color = Theme.spark
    let onNext: () -> Void

    @State private var picked: Int?

    private var pickedIsBest: Bool {
        guard let picked else { return false }
        return game.options[picked].isBest
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                VStack(spacing: 10) {
                    Label("Better Asking", systemImage: "wand.and.stars")
                        .sprocketFont(22, .heavy).foregroundStyle(Theme.ink)
                    Text(game.intro).sprocketFont(15).foregroundStyle(Theme.inkSoft)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                // The goal
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "target").foregroundStyle(tint)
                    Text(game.task).sprocketFont(15, .semibold).foregroundStyle(Theme.ink)
                    Spacer(minLength: 0)
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 14).fill(tint.opacity(0.10)))
                .padding(.horizontal, 20)

                Text("Tap a way of asking to see what the AI would do:")
                    .sprocketFont(13, .medium).foregroundStyle(Theme.inkFaint)

                VStack(spacing: 12) {
                    ForEach(Array(game.options.enumerated()), id: \.element.id) { i, option in
                        optionCard(i, option)
                    }
                }
                .padding(.horizontal, 20)

                if picked != nil {
                    Button("Next") { Haptics.shared.tap(); onNext() }
                        .buttonStyle(.sprocket(tint, filled: pickedIsBest))
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                    if !pickedIsBest {
                        Text("Tip: try tapping the clearest, most specific prompt.")
                            .sprocketFont(12).foregroundStyle(Theme.inkFaint)
                    }
                }
                Color.clear.frame(height: 12)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: picked)
    }

    private func optionCard(_ i: Int, _ option: PromptImproverGame.Option) -> some View {
        let isPicked = picked == i
        let reveal = isPicked
        return Button {
            guard picked != i else { return }
            picked = i
            option.isBest ? Haptics.shared.win() : Haptics.shared.tryAgain()
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "text.bubble.fill")
                        .foregroundStyle(reveal ? (option.isBest ? Theme.correct : Theme.gentle) : tint)
                    Text(option.text)
                        .sprocketFont(15, .semibold)
                        .foregroundStyle(Theme.ink)
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: 0)
                    if reveal {
                        Image(systemName: option.isBest ? "star.fill" : "arrow.uturn.left")
                            .foregroundStyle(option.isBest ? Theme.correct : Theme.gentle)
                    }
                }
                if reveal {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "arrow.turn.down.right").foregroundStyle(Theme.inkFaint)
                        Text(option.result)
                            .sprocketFont(14)
                            .foregroundStyle(Theme.inkSoft)
                            .multilineTextAlignment(.leading)
                    }
                    .transition(.opacity)
                }
            }
            .padding(15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(reveal ? (option.isBest ? Theme.correctBG : Theme.gentleBG).opacity(0.55) : Theme.ground2)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(reveal ? (option.isBest ? Theme.correct : Theme.gentle) : Theme.line,
                                          lineWidth: 2)
                    }
            }
        }
        .buttonStyle(.plain)
    }
}
