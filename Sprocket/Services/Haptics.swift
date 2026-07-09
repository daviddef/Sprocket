import UIKit

/// Thin wrapper over UIKit's feedback generators, adapted from Fernby's
/// Haptics. Generators are kept warm with `prepare()` for low-latency taps.
/// No-ops on the Simulator (no Taptic Engine) but works on device.
///
/// Same deliberate rule as Fernby: there is no sharp `.error` buzz anywhere.
/// A wrong answer gets a soft impact at most — mistakes are never punished,
/// including at the haptic layer.
final class Haptics {
    static let shared = Haptics()

    private let selection = UISelectionFeedbackGenerator()
    private let soft = UIImpactFeedbackGenerator(style: .soft)
    private let light = UIImpactFeedbackGenerator(style: .light)
    private let success = UINotificationFeedbackGenerator()

    var enabled: Bool {
        didSet { UserDefaults.standard.set(enabled, forKey: "sprocket.hapticsEnabled") }
    }

    private init() {
        enabled = UserDefaults.standard.object(forKey: "sprocket.hapticsEnabled") as? Bool ?? true
    }

    func prepareAll() {
        guard enabled else { return }
        [soft, light].forEach { $0.prepare() }
        selection.prepare()
        success.prepare()
    }

    /// Any button/tile tap.
    func tap() {
        guard enabled else { return }
        selection.selectionChanged()
        selection.prepare()
    }

    /// A correct answer or a completed unit — the one celebratory cue.
    func win() {
        guard enabled else { return }
        success.notificationOccurred(.success)
    }

    /// A gentle "not quite" — soft, never harsh.
    func tryAgain() {
        guard enabled else { return }
        soft.impactOccurred(intensity: 0.6)
        soft.prepare()
    }
}
