import SwiftUI

/// The single palette + type source for the app. Colors are the ones pinned
/// in the product-design brief: a warm paper ground, an energetic "spark"
/// accent, and one signature hue per age tier so a child (and a parent)
/// always knows which track they're in. Every color is defined in code so
/// there is exactly one place to change them.
enum Theme {
    // Brand
    static let spark      = Color(hex: 0xE4572E)   // accent — the "spark"
    static let sparkDeep  = Color(hex: 0xB83E1C)

    // Neutrals (warm, chosen — not default grey)
    static let ground     = Color(hex: 0xF5F2EB)
    static let ground2    = Color(hex: 0xFFFFFF)
    static let ground3    = Color(hex: 0xEDE8DD)
    static let line       = Color(hex: 0xDED8CB)
    static let ink        = Color(hex: 0x1B2A31)
    static let inkSoft    = Color(hex: 0x556169)
    static let inkFaint   = Color(hex: 0x8A939A)

    // Semantic (kept separate from the accent hue)
    static let correct    = Color(hex: 0x2E7D54)
    static let correctBG  = Color(hex: 0xDFF0E4)
    static let gentle     = Color(hex: 0xB87400)   // "not quite" — never a harsh red
    static let gentleBG   = Color(hex: 0xF7ECD3)

    // Tier hues
    static let sprouts    = Color(hex: 0xE0972A)
    static let sproutsBG  = Color(hex: 0xFBF0D9)
    static let explorers  = Color(hex: 0x1F9A8A)
    static let explorersBG = Color(hex: 0xDDF1ED)
    static let builders   = Color(hex: 0x5666C4)
    static let buildersBG = Color(hex: 0xE4E6F7)
}

extension Color {
    /// 0xRRGGBB literal → Color. Keeps the palette readable in one glance.
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red:   Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue:  Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

extension Font {
    /// The app speaks in one rounded voice at a small set of sizes.
    static func sprocket(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}
