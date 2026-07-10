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
    @State private var showAddChild = false
    @State private var childToRemove: LearnerProfile?

    private var track: [Unit] { store.track }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    childrenCard
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
            .sheet(isPresented: $showAddChild) { AddChildView() }
            .confirmationDialog(
                childToRemove.map { "Remove \($0.name) and delete their progress?" } ?? "",
                isPresented: Binding(get: { childToRemove != nil },
                                     set: { if !$0 { childToRemove = nil } }),
                titleVisibility: .visible
            ) {
                Button("Remove child", role: .destructive) {
                    if let c = childToRemove { store.removeProfile(c.id) }
                    childToRemove = nil
                }
                Button("Cancel", role: .cancel) { childToRemove = nil }
            }
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

    /// Every child on this device. One subscription covers all of them, so the
    /// family list is the first thing a paying parent should see.
    private var childrenCard: some View {
        card {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    cardTitle(store.profiles.count > 1 ? "Children" : "Child")
                    Spacer()
                    Text("\(store.profiles.count)/\(ProgressStore.maxChildren)")
                        .font(.sprocket(12, .semibold)).foregroundStyle(Theme.inkFaint)
                        .monospacedDigit()
                }

                ForEach(store.profiles) { child in
                    childRow(child)
                    if child.id != store.profiles.last?.id { Divider() }
                }

                Button {
                    Haptics.shared.tap(); showAddChild = true
                } label: {
                    Label("Add a child", systemImage: "plus.circle.fill")
                        .font(.sprocket(15, .bold))
                        .foregroundStyle(store.canAddChild ? Theme.spark : Theme.inkFaint)
                }
                .disabled(!store.canAddChild)
                .padding(.top, 2)

                if !store.canAddChild {
                    Text("Maximum of \(ProgressStore.maxChildren) children per device.")
                        .font(.sprocket(11)).foregroundStyle(Theme.inkFaint)
                }
            }
        }
    }

    private func childRow(_ child: LearnerProfile) -> some View {
        let active = child.id == store.activeProfileID
        let total = Curriculum.track(for: child.tier).count
        return HStack(spacing: 12) {
            Text(String(child.name.first.map(String.init) ?? "?").uppercased())
                .font(.sprocket(18, .heavy)).foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Circle().fill(child.tier.color))
                .overlay(alignment: .bottomTrailing) {
                    if active {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.correct)
                            .background(Circle().fill(.white))
                            .offset(x: 2, y: 2)
                    }
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(child.name).font(.sprocket(17, .bold))
                Text("\(child.tier.name) · \(store.completedCount(for: child))/\(total) lessons · \(store.xp(for: child)) XP")
                    .font(.sprocket(11)).foregroundStyle(Theme.inkFaint)
            }
            Spacer(minLength: 4)

            Menu {
                if !active {
                    Button {
                        store.switchTo(child.id); haptics = Haptics.shared.enabled
                    } label: { Label("Make active", systemImage: "person.fill.checkmark") }
                }
                Menu("Change track") {
                    ForEach(Tier.allCases) { tier in
                        Button {
                            store.setTier(tier, for: child.id)
                        } label: {
                            Label("\(tier.name) (\(tier.ageRange))",
                                  systemImage: tier == child.tier ? "checkmark" : tier.symbol)
                        }
                    }
                }
                Divider()
                Button(role: .destructive) { childToRemove = child } label: {
                    Label("Remove child", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 20)).foregroundStyle(Theme.inkSoft)
            }
            .accessibilityLabel("Manage \(child.name)")
        }
    }

    private var progressCard: some View {
        card {
            VStack(alignment: .leading, spacing: 14) {
                cardTitle("\(store.activeProfile?.name ?? "Learner")'s Progress")
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
                    Label("Remove all children & data", systemImage: "trash")
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

/// Adding a child, from inside the grown-up area. Same two decisions as
/// first-run onboarding — a name and an age track — minus the welcome.
struct AddChildView: View {
    @EnvironmentObject private var store: ProgressStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var tier: Tier = .explorers

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    TextField("Name or nickname", text: $name)
                        .font(.sprocket(18, .semibold))
                        .multilineTextAlignment(.center)
                        .textInputAutocapitalization(.words)
                        .padding(16)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Theme.ground2))
                        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Theme.line))

                    Text("Pick their track").font(.sprocket(15, .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ForEach(Tier.allCases) { t in
                        Button {
                            Haptics.shared.tap(); tier = t
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: t.symbol)
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundStyle(t.color)
                                    .frame(width: 48, height: 48)
                                    .background(Circle().fill(t.softColor))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(t.name).font(.sprocket(17, .bold)).foregroundStyle(Theme.ink)
                                    Text(t.ageRange).font(.sprocket(12, .semibold)).foregroundStyle(t.color)
                                    Text(t.tagline).font(.sprocket(11)).foregroundStyle(Theme.inkSoft)
                                }
                                Spacer()
                                Image(systemName: tier == t ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 22))
                                    .foregroundStyle(tier == t ? t.color : Theme.line)
                            }
                            .padding(14)
                            .background {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Theme.ground2)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .strokeBorder(tier == t ? t.color : Theme.line,
                                                          lineWidth: tier == t ? 2.5 : 1)
                                    }
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    Button("Add Child") {
                        store.createProfile(name: name.trimmingCharacters(in: .whitespaces), tier: tier)
                        dismiss()
                    }
                    .buttonStyle(.sprocket(tier.color))
                    .padding(.top, 4)
                }
                .padding(20)
            }
            .background(Theme.ground.ignoresSafeArea())
            .navigationTitle("Add a Child")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
