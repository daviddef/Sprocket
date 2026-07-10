import SwiftUI

/// Sprocket — a tiered course that teaches kids (ages 5–17) what AI is, how it
/// works, what prompts are, and how to use it responsibly. "Sprocket" is the
/// mascot's name — a friendly little thinking machine (a sprocket is a gear).
///
/// Architecture mirrors the sibling Fernby app deliberately: one shared
/// `ProgressStore` (UserDefaults + Codable) as the single source of truth,
/// SwiftUI throughout, rounded system type, iPhone-only, and light mode
/// forced app-wide (every color here was chosen against a light ground and
/// has never been designed for Dark Mode — see Fernby's note; same call).
@main
struct SprocketApp: App {
    @StateObject private var store = ProgressStore.shared
    @StateObject private var entitlements = EntitlementStore.shared

    init() {
        #if DEBUG
        DebugSeed.applyIfRequested()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            rootContent
                .environmentObject(store)
                .environmentObject(entitlements)
                .tint(Theme.spark)
                .preferredColorScheme(.light)
        }
    }

    @ViewBuilder
    private var rootContent: some View {
        #if DEBUG
        // Manual-QA hook: launch with SPROCKET_DEBUG_UNIT=<unit id> (e.g.
        // "sprouts.1") to jump straight into that unit's lesson player, or
        // SPROCKET_DEBUG_TIER=<tier> to seed a profile and land on the home map —
        // no tapping through onboarding to screenshot a deep screen.
        let env = ProcessInfo.processInfo.environment
        if let unitID = env["SPROCKET_DEBUG_UNIT"], let unit = Curriculum.unit(id: unitID) {
            LessonPlayerView(unit: unit,
                             startIndex: Int(env["SPROCKET_DEBUG_SCREEN"] ?? "") ?? 0)
        } else if env["SPROCKET_DEBUG_VIEW"] == "parent" {
            ParentDashboardView()
        } else if env["SPROCKET_DEBUG_VIEW"] == "paywall" {
            PaywallView()
        } else if env["SPROCKET_DEBUG_VIEW"] == "trophies" {
            TrophyRoomView()
        } else if env["SPROCKET_DEBUG_VIEW"] == "picker" {
            ProfilePickerView()
        } else {
            RootView()
        }
        #else
        RootView()
        #endif
    }
}

#if DEBUG
/// Launch-argument gated seeding so it can never fire in release.
///
/// - `SPROCKET_DEBUG_TIER=explorers` + optional `SPROCKET_DEBUG_DONE=3`
///   creates one child on that track with N units complete.
/// - `SPROCKET_DEBUG_KIDS="Sam:explorers:3,Mia:sprouts:1"` seeds a whole
///   family (name:tier:unitsDone), for exercising the multi-child switcher.
///   The first child listed ends up active.
enum DebugSeed {
    @MainActor
    static func applyIfRequested() {
        let env = ProcessInfo.processInfo.environment
        let store = ProgressStore.shared

        if let kids = env["SPROCKET_DEBUG_KIDS"], store.profiles.isEmpty {
            var firstID: UUID?
            for spec in kids.split(separator: ",") {
                let parts = spec.split(separator: ":").map(String.init)
                guard parts.count >= 2, let tier = Tier(rawValue: parts[1]) else { continue }
                let profile = store.createProfile(name: parts[0], tier: tier)
                if firstID == nil { firstID = profile.id }
                let done = parts.count > 2 ? (Int(parts[2]) ?? 0) : 0
                for unit in Curriculum.track(for: tier).prefix(done) {
                    store.completeUnit(unit, correct: 3, total: 3)
                }
            }
            if let firstID { store.switchTo(firstID) }
            return
        }

        guard let raw = env["SPROCKET_DEBUG_TIER"], let tier = Tier(rawValue: raw) else { return }
        if store.activeProfile == nil {
            store.createProfile(name: "Sam", tier: tier)
        }
        if let doneRaw = env["SPROCKET_DEBUG_DONE"], let done = Int(doneRaw) {
            for unit in Curriculum.track(for: tier).prefix(done) {
                store.completeUnit(unit, correct: 3, total: 3)
            }
        }
    }
}
#endif
