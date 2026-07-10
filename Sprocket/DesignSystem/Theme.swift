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

/// The app speaks in one rounded voice at a small set of sizes — and every one
/// of them now scales with the reader's Dynamic Type setting.
///
/// This has to be a `ViewModifier` rather than a `Font` factory: SwiftUI's
/// `Font.system(size:)` is a *fixed* point size and ignores Dynamic Type
/// entirely (verified in the simulator — at `accessibility-extra-large` the
/// old `Font.sprocket` rendered pixel-identical to the default size). Only
/// `@ScaledMetric` tracks the accessibility text size, and it has to live on a
/// View to stay reactive when the setting changes while the app is running.
private struct SprocketFont: ViewModifier {
    // Declared bare: the storage is initialised in `init` so `relativeTo`
    // can be supplied alongside the caller's size.
    @ScaledMetric private var scaledSize: CGFloat
    private let weight: Font.Weight

    init(size: CGFloat, weight: Font.Weight) {
        _scaledSize = ScaledMetric(wrappedValue: size, relativeTo: .body)
        self.weight = weight
    }

    func body(content: Content) -> some View {
        content.font(.system(size: scaledSize, weight: weight, design: .rounded))
    }
}

extension View {
    /// Rounded system type at `size`, scaled for the reader's text-size setting.
    func sprocketFont(_ size: CGFloat, _ weight: Font.Weight = .regular) -> some View {
        modifier(SprocketFont(size: size, weight: weight))
    }

    /// Honour the system "Reduce Motion" setting for everything below this view.
    ///
    /// Applied once at the root rather than at each of the ~15 `.animation`
    /// call sites, because a transaction mutation also catches the imperative
    /// `withAnimation { … }` blocks in the mini-games, which per-call-site
    /// edits would silently miss.
    func respectingReduceMotion() -> some View {
        modifier(ReduceMotionRoot())
    }
}

private struct ReduceMotionRoot: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content.transaction { transaction in
            if reduceMotion { transaction.animation = nil }
        }
    }
}
