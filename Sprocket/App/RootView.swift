import SwiftUI

/// Top-level router. A child who hasn't been set up yet (no profile) lands
/// on onboarding, which is gated by a grown-up check before a track/age is
/// chosen — the tier is a parental decision, not a child's. Once a profile
/// exists, the home skill map is the one screen worth entering at.
struct RootView: View {
    @EnvironmentObject private var store: ProgressStore

    var body: some View {
        Group {
            if store.activeProfile == nil {
                OnboardingView()
            } else {
                HomeView()
            }
        }
        .animation(.easeInOut(duration: 0.35), value: store.activeProfile == nil)
    }
}
