import SwiftUI

/// The grown-up area, reached only through the parent gate. Shows what the
/// child has learned, exposes the controls parents value most (the #1
/// willingness-to-pay driver in the research), and states the privacy
/// posture plainly — which is a feature, not fine print.
struct ParentDashboardView: View {
    @EnvironmentObject private var store: ProgressStore
    @EnvironmentObject private var entitlements: EntitlementStore
    @Environment(\.dismiss) private var dismiss

    @State private var haptics = Haptics.shared.enabled
    @State private var confirmReset = false
    @State private var confirmDelete = false
    @State private var showPaywall = false

    private var track: [Unit] { store.track }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    childCard
                    plusCard
                    progressCard
                    bigIdeasCard
                    if !store.badges.isEmpty { badgesCard }
                    settingsCard
                    privacyCard
                    dangerZone
                    Color.clear.frame(height: 8)
                }
                .padding(20)
            }
            .background(Theme.ground.ignoresSafeArea())
            .navigationTitle("Grown-Up Area")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }.font(.sprocket(16, .bold))
                }
            }
            .sheet(isPresented: $showPaywall) { PaywallView() }
        }
    }

    private var plusCard: some View {
        card(tint: entitlements.isSubscribed ? Theme.correctBG : Theme.sproutsBG) {
            HStack(spacing: 14) {
                Image(systemName: entitlements.isSubscribed ? "checkmark.seal.fill" : "crown.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(entitlements.isSubscribed ? Theme.correct : Theme.spark)
                    .frame(width: 46, height: 46)
                    .background(Circle().fill(Theme.ground2))
                VStack(alignment: .leading, spacing: 2) {
                    Text(entitlements.isSubscribed ? "Sprocket Plus · Active" : "Sprocket Plus")
                        .font(.sprocket(16, .bold))
                    Text(entitlements.isSubscribed
                         ? "Every lesson unlocked. Manage in device Settings."
                         : "Unlock every lesson & track for the whole family.")
                        .font(.sprocket(12)).foregroundStyle(Theme.inkSoft)
                }
                Spacer(minLength: 8)
                if !entitlements.isSubscribed {
                    Button("See Plans") { Haptics.shared.tap(); showPaywall = true }
                        .font(.sprocket(13, .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14).padding(.vertical, 9)
                        .background(Capsule().fill(Theme.spark))
                }
            }
        }
    }

    // MARK: Cards

    private var childCard: some View {
        card {
            HStack(spacing: 14) {
                Image(systemName: store.tier.symbol)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(store.tier.color)
                    .frame(width: 52, height: 52)
                    .background(Circle().fill(store.tier.softColor))
                VStack(alignment: .leading, spacing: 2) {
                    Text(store.activeProfile?.name ?? "Learner").font(.sprocket(20, .bold))
                    Text("\(store.tier.name) · \(store.tier.ageRange)")
                        .font(.sprocket(13, .semibold)).foregroundStyle(store.tier.color)
                }
                Spacer()
                Menu {
                    ForEach(Tier.allCases) { tier in
                        Button {
                            store.setActiveTier(tier); haptics = Haptics.shared.enabled
                        } label: {
                            Label("\(tier.name) (\(tier.ageRange))",
                                  systemImage: tier == store.tier ? "checkmark" : tier.symbol)
                        }
                    }
                } label: {
                    Text("Change track").font(.sprocket(13, .semibold))
                }
            }
        }
    }

    private var progressCard: some View {
        card {
            VStack(alignment: .leading, spacing: 14) {
                cardTitle("Progress")
                HStack(spacing: 12) {
                    stat("\(store.completedCount)/\(track.count)", "Lessons", Theme.explorers)
                    stat("\(store.xp)", "XP", Theme.spark)
                    stat("\(store.currentStreak)", "Day streak", Theme.sprouts)
                    stat("\(store.longestStreak)", "Best streak", Theme.builders)
                }
                ProgressView(value: Double(store.completedCount), total: Double(max(1, track.count)))
                    .tint(store.tier.color)
            }
        }
    }

    private var bigIdeasCard: some View {
        card {
            VStack(alignment: .leading, spacing: 12) {
                cardTitle("The Five Big Ideas")
                Text("Sprocket's curriculum follows the AI4K12 national framework.")
                    .font(.sprocket(13)).foregroundStyle(Theme.inkSoft)
                ForEach(BigIdea.allCases) { idea in
                    let units = Curriculum.units(in: store.tier, idea: idea)
                    let done = units.filter { store.isCompleted($0.id) }.count
                    HStack(spacing: 10) {
                        Image(systemName: idea.symbol)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(idea.color)
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(idea.color.opacity(0.14)))
                        VStack(alignment: .leading, spacing: 1) {
                            Text(idea.title).font(.sprocket(14, .semibold))
                            Text(idea.kidTitle).font(.sprocket(11)).foregroundStyle(Theme.inkFaint)
                        }
                        Spacer()
                        if !units.isEmpty {
                            Text("\(done)/\(units.count)")
                                .font(.sprocket(13, .bold)).monospacedDigit()
                                .foregroundStyle(done == units.count && done > 0 ? Theme.correct : Theme.inkSoft)
                        }
                    }
                }
            }
        }
    }

    private var badgesCard: some View {
        card {
            VStack(alignment: .leading, spacing: 12) {
                cardTitle("Badges Earned")
                let cols = [GridItem(.adaptive(minimum: 70), spacing: 12)]
                LazyVGrid(columns: cols, spacing: 14) {
                    ForEach(store.badges) { badge in
                        VStack(spacing: 5) {
                            Image(systemName: badge.symbol)
                                .font(.system(size: 20, weight: .bold)).foregroundStyle(.white)
                                .frame(width: 46, height: 46)
                                .background(Circle().fill(badge.color))
                            Text(badge.title).font(.sprocket(10, .semibold))
                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }
        }
    }

    private var settingsCard: some View {
        card {
            VStack(alignment: .leading, spacing: 6) {
                cardTitle("Settings")
                Toggle(isOn: Binding(
                    get: { store.narrationEnabled },
                    set: { store.narrationEnabled = $0 })) {
                    settingLabel("Read aloud", "Narrate lessons automatically", "speaker.wave.2.fill")
                }
                .tint(store.tier.color)
                Divider()
                Toggle(isOn: $haptics) {
                    settingLabel("Gentle taps", "Soft haptic feedback", "hand.tap.fill")
                }
                .tint(store.tier.color)
                .onChange(of: haptics) { _, on in Haptics.shared.enabled = on }
            }
        }
    }

    private var privacyCard: some View {
        card(tint: Theme.correctBG) {
            VStack(alignment: .leading, spacing: 8) {
                Label("Private by design", systemImage: "lock.shield.fill")
                    .font(.sprocket(16, .bold)).foregroundStyle(Theme.correct)
                privacyLine("No account or sign-up needed")
                privacyLine("No ads and no third-party tracking")
                privacyLine("No personal data leaves this device")
                privacyLine("Lessons work fully offline")
            }
        }
    }

    private var dangerZone: some View {
        card {
            VStack(alignment: .leading, spacing: 12) {
                cardTitle("Manage Data")
                Button {
                    confirmReset = true
                } label: {
                    Label("Reset progress", systemImage: "arrow.counterclockwise")
                        .font(.sprocket(15, .semibold)).foregroundStyle(Theme.gentle)
                }
                Divider()
                Button {
                    confirmDelete = true
                } label: {
                    Label("Remove child & all data", systemImage: "trash")
                        .font(.sprocket(15, .semibold)).foregroundStyle(Theme.spark)
                }
            }
        }
        .confirmationDialog("Reset all progress for this child?",
                            isPresented: $confirmReset, titleVisibility: .visible) {
            Button("Reset progress", role: .destructive) { store.resetActiveProfileData() }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog("Remove this child and delete everything on this device?",
                            isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Delete everything", role: .destructive) { store.deleteEverything(); dismiss() }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: Bits

    private func card<Content: View>(tint: Color = Theme.ground2,
                                     @ViewBuilder _ content: () -> Content) -> some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(tint))
    }

    private func cardTitle(_ text: String) -> some View {
        Text(text).font(.sprocket(17, .bold)).foregroundStyle(Theme.ink)
    }

    private func stat(_ value: String, _ label: String, _ tint: Color) -> some View {
        VStack(spacing: 3) {
            Text(value).font(.sprocket(20, .heavy)).foregroundStyle(tint).monospacedDigit()
            Text(label).font(.sprocket(11, .medium)).foregroundStyle(Theme.inkFaint)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private func settingLabel(_ title: String, _ sub: String, _ icon: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon).foregroundStyle(store.tier.color).frame(width: 24)
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.sprocket(15, .semibold)).foregroundStyle(Theme.ink)
                Text(sub).font(.sprocket(11)).foregroundStyle(Theme.inkFaint)
            }
        }
    }

    private func privacyLine(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 13)).foregroundStyle(Theme.correct)
            Text(text).font(.sprocket(13)).foregroundStyle(Theme.ink)
        }
    }
}

extension ProgressStore {
    /// Lets a parent move the child to a different age track (and resets the
    /// narration default to match). Mutating the profile persists via didSet.
    func setActiveTier(_ tier: Tier) {
        guard let idx = profiles.firstIndex(where: { $0.id == activeProfileID }) else { return }
        profiles[idx].tier = tier
        narrationEnabled = tier.narrationOnByDefault
    }
}
