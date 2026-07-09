import SwiftUI

/// What a child sees when they tap a premium-locked lesson. Warm and
/// pressure-free — no price, no purchase button — it just points them to a
/// grown-up, who then passes the parent gate to reach the actual paywall.
struct UnlockPromptView: View {
    var tint: Color = Theme.spark
    let onAskGrownUp: () -> Void
    let onLater: () -> Void

    var body: some View {
        VStack(spacing: 22) {
            Spacer()
            MascotView(mood: .happy, size: 96, tint: tint)
            Text("More to explore!")
                .font(.sprocket(26, .heavy))
            Text("There are lots more lessons and games ahead. Ask a grown-up to unlock the full adventure.")
                .font(.sprocket(16))
                .foregroundStyle(Theme.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
            Spacer()
            VStack(spacing: 12) {
                Button("Get a Grown-Up") { Haptics.shared.tap(); onAskGrownUp() }
                    .buttonStyle(.sprocket(tint))
                Button("Maybe Later") { Haptics.shared.tap(); onLater() }
                    .buttonStyle(.sprocket(Theme.inkSoft, filled: false))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.ground.ignoresSafeArea())
    }
}
