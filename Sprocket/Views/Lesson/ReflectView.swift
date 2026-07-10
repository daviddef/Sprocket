import SwiftUI

/// A pause-and-choose beat with no wrong answer — used for the reflect moment
/// and for softer social/ethical prompts. Any pick is valid; picking just
/// makes the choice feel intentional before moving on.
struct ReflectView: View {
    let prompt: ReflectPrompt
    var tint: Color = Theme.spark
    let onNext: () -> Void

    @EnvironmentObject private var store: ProgressStore
    @State private var picked: Int?

    private var narrating: Bool { store.narrationEnabled }

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 8)

            Image(systemName: "bubble.left.and.text.bubble.right.fill")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(tint)

            HStack(alignment: .top, spacing: 10) {
                Text(prompt.prompt)
                    .sprocketFont(22, .bold)
                    .multilineTextAlignment(.center)
                SpeakerButton(text: prompt.narration ?? prompt.prompt, autoNarrate: true)
            }
            .padding(.horizontal, 24)

            Text("There's no wrong answer here.")
                .sprocketFont(13, .medium)
                .foregroundStyle(Theme.inkFaint)

            VStack(spacing: 12) {
                ForEach(Array(prompt.options.enumerated()), id: \.offset) { i, option in
                  HStack(spacing: 8) {
                    // Speaker sits beside the choice, never nested inside it.
                    Button {
                        Haptics.shared.tap(); picked = i
                    } label: {
                        Text(option)
                            .sprocketFont(17, .semibold)
                            .foregroundStyle(picked == i ? .white : Theme.ink)
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(picked == i ? tint : Theme.ground2)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .strokeBorder(picked == i ? tint : Theme.line, lineWidth: 2)
                                    }
                            }
                    }
                    .buttonStyle(.plain)
                    if narrating { SpeakerButton(text: option) }
                  }
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            Button(picked == nil ? "Skip" : "Next") { Haptics.shared.tap(); onNext() }
                .buttonStyle(.sprocket(tint, filled: picked != nil))
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
        }
        .animation(.easeInOut(duration: 0.2), value: picked)
    }
}
