import SwiftUI

/// The one primary button in the app: large, rounded, full-width, with a
/// gentle press scale (anticipation, not a flashy celebration). Filled by
/// default; `.soft` gives a quiet outlined variant for secondary actions.
struct SprocketButtonStyle: ButtonStyle {
    var tint: Color = Theme.spark
    var filled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .sprocketFont(19, .bold)
            .frame(maxWidth: .infinity, minHeight: 58)
            .padding(.horizontal, 16)
            .foregroundStyle(filled ? Color.white : tint)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(filled ? tint : Color.clear)
                    .overlay {
                        if !filled {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .strokeBorder(tint.opacity(0.4), lineWidth: 2)
                        }
                    }
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == SprocketButtonStyle {
    static var sprocket: SprocketButtonStyle { SprocketButtonStyle() }
    static func sprocket(_ tint: Color, filled: Bool = true) -> SprocketButtonStyle {
        SprocketButtonStyle(tint: tint, filled: filled)
    }
}
