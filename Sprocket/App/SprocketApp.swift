import SwiftUI

/// Sprocket — a tiered course that teaches kids (ages 5–17) what AI is, how it
/// works, what prompts are, and how to use it responsibly. Working title;
/// "Sprocket" is both the mascot's name and a nod to bite-sized lessons.
///
/// Architecture mirrors the sibling Fernby app deliberately: one shared
/// `ProgressStore` (UserDefaults + Codable) as the single source of truth,
/// SwiftUI throughout, rounded system type, iPhone-only, and light mode
/// forced app-wide (every color here was chosen against a light ground and
/// has never been designed for Dark Mode — see Fernby's note; same call).
@main
struct SprocketApp: App {
    @StateObject private var store = ProgressStore.shared

    init() {
        #if DEBUG
        DebugSeed.applyIfRequested()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            rootContent
                .environmentObject(store)
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
        } else {
            RootView()
        }
        #else
        RootView()
        #endif
    }
}

#if DEBUG
/// Launch-argument gated seeding so it can never fire in release. Set
/// SPROCKET_DEBUG_TIER to a tier raw value ("sprouts"/"explorers"/"builders") to
/// create a profile on that track, optionally SPROCKET_DEBUG_DONE to a count of
/// leading units to mark complete (to screenshot mid-progress maps).
enum DebugSeed {
    @MainActor
    static func applyIfRequested() {
        let env = ProcessInfo.processInfo.environment
        guard let raw = env["SPROCKET_DEBUG_TIER"], let tier = Tier(rawValue: raw) else { return }
        let store = ProgressStore.shared
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
