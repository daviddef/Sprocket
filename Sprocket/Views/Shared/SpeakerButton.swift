import SwiftUI

/// A tap-to-hear-it button that reads a line aloud. Always available (older
/// kids can tap it too), and — via `.autoNarrate` — speaks on appear when
/// the profile has narration on (Sprouts by default). Central to making the
/// youngest, pre-reading tier usable at all.
struct SpeakerButton: View {
    let text: String
    var autoNarrate: Bool = false

    @EnvironmentObject private var store: ProgressStore
    @StateObject private var speech = SpeechService.shared

    var body: some View {
        Button {
            Haptics.shared.tap()
            speech.speak(text)
        } label: {
            Image(systemName: "speaker.wave.2.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.spark)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Theme.spark.opacity(0.12)))
        }
        .accessibilityLabel("Read aloud")
        .onAppear {
            if autoNarrate && store.narrationEnabled {
                speech.speak(text)
            }
        }
        .onDisappear { speech.stop() }
    }
}
