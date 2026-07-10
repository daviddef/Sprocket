import SwiftUI

/// The two-bin sorter. One item is shown at a time; the child taps the bin it
/// belongs in. A wrong tap is corrected gently (it slides to the right bin
/// with a note) — never a failure state. Finishing all items completes the
/// game. Powers "Robot or Not?", "Cat or Dog?", "Good/Bad data", etc.
struct SortGameView: View {
    let game: SortGame
    var tint: Color = Theme.spark
    let onNext: () -> Void

    @State private var index = 0
    @State private var feedback: Feedback?

    private enum Feedback { case right, gentle(correctBin: String) }

    private var current: SortGame.Item? {
        index < game.items.count ? game.items[index] : nil
    }
    private var done: Bool { index >= game.items.count }

    var body: some View {
        VStack(spacing: 20) {
            header

            Spacer()

            if let item = current {
                itemCard(item)
                    .id(item.id)
                    .transition(.scale.combined(with: .opacity))
            } else {
                completeCard
            }

            Spacer()

            if done {
                Button("Next") { Haptics.shared.tap(); onNext() }
                    .buttonStyle(.sprocket(tint))
                    .padding(.horizontal, 24)
            } else {
                HStack(spacing: 14) {
                    binButton(game.binA, isA: true)
                    binButton(game.binB, isA: false)
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 20)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: index)
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text(game.title).sprocketFont(22, .heavy)
            HStack(alignment: .top, spacing: 8) {
                Text(game.intro)
                    .sprocketFont(15)
                    .foregroundStyle(Theme.inkSoft)
                    .multilineTextAlignment(.center)
                SpeakerButton(text: game.intro, autoNarrate: false)
            }
            ProgressView(value: Double(index), total: Double(game.items.count))
                .tint(tint)
                .padding(.top, 4)
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }

    private func itemCard(_ item: SortGame.Item) -> some View {
        VStack(spacing: 16) {
            Image(systemName: item.symbol)
                .font(.system(size: 60, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 150, height: 150)
                .background(RoundedRectangle(cornerRadius: 28, style: .continuous).fill(Theme.ground2))
                .shadow(color: Theme.ink.opacity(0.08), radius: 8, y: 4)
            Text(item.label).sprocketFont(22, .bold)

            if let feedback {
                switch feedback {
                case .right:
                    feedbackLabel("Yes! That's right.", Theme.correct, "checkmark.circle.fill")
                case .gentle(let bin):
                    feedbackLabel("Close! It goes in “\(bin)”.", Theme.gentle, "arrow.right.circle.fill")
                }
            }
        }
    }

    private func feedbackLabel(_ text: String, _ color: Color, _ icon: String) -> some View {
        Label(text, systemImage: icon)
            .sprocketFont(15, .semibold)
            .foregroundStyle(color)
            .transition(.opacity)
    }

    private var completeCard: some View {
        VStack(spacing: 14) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 56)).foregroundStyle(Theme.correct)
            Text("All sorted!").sprocketFont(24, .heavy)
            Text("Nice sorting. You've got the idea.")
                .sprocketFont(15).foregroundStyle(Theme.inkSoft)
        }
    }

    private func binButton(_ bin: SortGame.Bin, isA: Bool) -> some View {
        Button {
            guard let item = current, feedback == nil else { return }
            let correct = (item.inA == isA)
            if correct { Haptics.shared.win(); feedback = .right }
            else { Haptics.shared.tryAgain()
                   feedback = .gentle(correctBin: item.inA ? game.binA.label : game.binB.label) }
            DispatchQueue.main.asyncAfter(deadline: .now() + (correct ? 0.55 : 1.1)) {
                feedback = nil
                index += 1
            }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: bin.symbol).font(.system(size: 26, weight: .bold))
                Text(bin.label).sprocketFont(15, .bold).multilineTextAlignment(.center)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 96)
            .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(bin.color))
        }
        .buttonStyle(.plain)
        .disabled(feedback != nil)
    }
}
