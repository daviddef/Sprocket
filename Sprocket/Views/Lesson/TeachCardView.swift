import SwiftUI

/// A single "here's an idea" screen: one symbol, one thought, plainly told,
/// with a read-aloud button (auto-narrates for the youngest tier).
struct TeachCardView: View {
    let card: TeachCard
    var tint: Color = Theme.spark
    let onNext: () -> Void

    private var narration: String { card.narration ?? "\(card.title). \(card.body)" }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: card.symbol)
                .font(.system(size: 52, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 128, height: 128)
                .background(Circle().fill(tint.opacity(0.12)))

            VStack(spacing: 14) {
                HStack(alignment: .center, spacing: 10) {
                    Text(card.title)
                        .font(.sprocket(27, .heavy))
                        .multilineTextAlignment(.center)
                    SpeakerButton(text: narration, autoNarrate: true)
                }
                Text(card.body)
                    .font(.sprocket(18))
                    .foregroundStyle(Theme.inkSoft)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .padding(.horizontal, 28)

            Spacer()
            Spacer()

            Button("Next") { Haptics.shared.tap(); onNext() }
                .buttonStyle(.sprocket(tint))
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
        }
    }
}
