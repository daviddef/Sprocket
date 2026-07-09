import SwiftUI

/// Sprocket, the mascot — a friendly robot face built from shapes (no image
/// assets to ship or theme). Kept deliberately simple and warm: rounded
/// head, big calm eyes, a soft smile. One antenna "spark" ties it to the
/// brand accent.
struct MascotView: View {
    enum Mood { case happy, thinking, cheer }
    var mood: Mood = .happy
    var size: CGFloat = 96
    var tint: Color = Theme.spark

    var body: some View {
        ZStack {
            // Antenna
            VStack(spacing: 0) {
                Circle()
                    .fill(tint)
                    .frame(width: size * 0.12, height: size * 0.12)
                Rectangle()
                    .fill(Theme.inkSoft.opacity(0.6))
                    .frame(width: size * 0.04, height: size * 0.14)
            }
            .offset(y: -size * 0.62)

            // Head
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(Theme.ground2)
                .overlay {
                    RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                        .strokeBorder(tint.opacity(0.85), lineWidth: size * 0.05)
                }
                .frame(width: size, height: size * 0.9)
                .shadow(color: Theme.ink.opacity(0.08), radius: 6, y: 3)

            // Face
            VStack(spacing: size * 0.12) {
                HStack(spacing: size * 0.22) {
                    eye
                    eye
                }
                mouth
            }
        }
        .frame(width: size, height: size * 1.4)
        .accessibilityHidden(true)
    }

    private var eye: some View {
        Group {
            switch mood {
            case .happy, .cheer:
                Circle().fill(Theme.ink).frame(width: size * 0.13, height: size * 0.13)
            case .thinking:
                Capsule().fill(Theme.ink).frame(width: size * 0.13, height: size * 0.05)
            }
        }
    }

    private var mouth: some View {
        Group {
            switch mood {
            case .happy:
                RoundedRectangle(cornerRadius: size * 0.05)
                    .fill(tint)
                    .frame(width: size * 0.3, height: size * 0.07)
            case .cheer:
                Circle().fill(tint).frame(width: size * 0.22, height: size * 0.22)
            case .thinking:
                Circle().fill(tint).frame(width: size * 0.08, height: size * 0.08)
                    .offset(x: size * 0.1)
            }
        }
    }
}
