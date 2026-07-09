import AVFoundation

/// Reads lesson text aloud for pre-readers (Sprouts) and anyone who taps the
/// speaker. On-device AVSpeechSynthesizer — no network, no data leaves the
/// device, which keeps the youngest tier's narration inside the app's
/// privacy-safe boundary.
@MainActor
final class SpeechService: ObservableObject {
    static let shared = SpeechService()

    private let synth = AVSpeechSynthesizer()
    @Published private(set) var isSpeaking = false

    private init() {
        // A low-priority, mixable session so narration ducks rather than
        // fights other audio, and never interrupts music the parent has on.
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers, .duckOthers])
    }

    func speak(_ text: String) {
        stop()
        try? AVAudioSession.sharedInstance().setActive(true)
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.44                 // a touch slower than default, for young ears
        utterance.pitchMultiplier = 1.06
        utterance.postUtteranceDelay = 0.1
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        isSpeaking = true
        synth.speak(utterance)
    }

    func stop() {
        if synth.isSpeaking { synth.stopSpeaking(at: .immediate) }
        isSpeaking = false
    }
}
