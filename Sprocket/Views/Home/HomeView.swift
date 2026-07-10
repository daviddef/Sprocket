import SwiftUI

/// The home screen and the one surface worth entering at: a vertical "path"
/// of unit nodes the child climbs, with a compact stats header (XP + streak)
/// and a grown-up gate into the parent area. Tapping an open node opens the
/// lesson; tapping a premium-locked node shows a gentle "ask a grown-up"
/// prompt that routes — through the parent gate — to the paywall. A child is
/// never shown a purchase button.
struct HomeView: View {
    @EnvironmentObject private var store: ProgressStore
    @EnvironmentObject private var entitlements: EntitlementStore

    @State private var activeUnit: Unit?
    @State private var activeSheet: ActiveSheet?

    private var track: [Unit] { store.track }

    private enum GateTarget { case parent, paywall }
    private enum ActiveSheet: Identifiable {
        case gate(GateTarget), parent, unlock, paywall, trophies, picker
        var id: String {
            switch self {
            case .gate(let t): return "gate-\(t == .parent ? "p" : "pay")"
            case .parent:   return "parent"
            case .unlock:   return "unlock"
            case .paywall:  return "paywall"
            case .trophies: return "trophies"
            case .picker:   return "picker"
            }
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            store.tier.softColor.opacity(0.5).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    Color.clear.frame(height: 120)   // room for the pinned header
                    mapPath
                    if trackComplete { graduationBanner.padding(.top, 24) }
                    Color.clear.frame(height: 40)
                }
            }

            header
        }
        .fullScreenCover(item: $activeUnit) { unit in
            LessonPlayerView(unit: unit)
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .gate(let target):
                ParentGateView(
                    onPassed: { activeSheet = (target == .parent) ? .parent : .paywall },
                    onCancel: { activeSheet = nil })
            case .parent:
                ParentDashboardView()
            case .unlock:
                UnlockPromptView(
                    tint: store.tier.color,
                    onAskGrownUp: { activeSheet = .gate(.paywall) },
                    onLater: { activeSheet = nil })
            case .paywall:
                PaywallView()
            case .trophies:
                TrophyRoomView()
            case .picker:
                ProfilePickerView()
            }
        }
        .onAppear { Haptics.shared.prepareAll() }
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: 14) {
            // With siblings on the device, the greeting doubles as the
            // "who's learning?" switcher. With one child there's nothing to
            // switch to, so it stays plain text.
            Button {
                guard store.profiles.count > 1 else { return }
                Haptics.shared.tap(); activeSheet = .picker
            } label: {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 5) {
                        Text(greeting)
                            .sprocketFont(22, .heavy)
                            .foregroundStyle(Theme.ink)
                        if store.profiles.count > 1 {
                            Image(systemName: "chevron.down.circle.fill")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Theme.inkFaint)
                        }
                    }
                    Text(store.tier.name + " · " + store.tier.ageRange)
                        .sprocketFont(13, .semibold)
                        .foregroundStyle(store.tier.color)
                }
                // The header is tight: a long name plus the switcher chevron
                // would otherwise wrap "Explorers · Ages 9–12" onto two lines.
                // Scale down hard rather than truncate — at large text sizes
                // 0.8 still produced "Hi, Sa…" and "Explorers ·…".
                .lineLimit(1)
                .minimumScaleFactor(0.55)
            }
            .buttonStyle(.plain)
            .disabled(store.profiles.count <= 1)
            .accessibilityLabel(store.profiles.count > 1 ? "Switch child" : greeting)
            Spacer()
            statChip(icon: "bolt.fill", value: "\(store.xp)", tint: Theme.spark)
            statChip(icon: "flame.fill", value: "\(store.currentStreak)", tint: Theme.sprouts)
            Button {
                Haptics.shared.tap(); activeSheet = .trophies
            } label: {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(store.tier.color)
            }
            .accessibilityLabel("My trophies")
            Button {
                Haptics.shared.tap(); activeSheet = .gate(.parent)
            } label: {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 26))
                    .foregroundStyle(Theme.inkSoft)
            }
            .accessibilityLabel("Grown-up area")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial)
        .overlay(alignment: .bottom) { Divider() }
    }

    private func statChip(icon: String, value: String, tint: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon).font(.system(size: 13, weight: .bold))
            Text(value).sprocketFont(15, .bold).monospacedDigit()
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(tint.opacity(0.14)))
    }

    private var greeting: String {
        let name = store.activeProfile?.name ?? "there"
        return "Hi, \(name)!"
    }

    // MARK: Map

    private var mapPath: some View {
        VStack(spacing: 0) {
            ForEach(Array(track.enumerated()), id: \.element.id) { index, unit in
                let state = nodeState(for: unit)
                UnitNodeView(
                    unit: unit,
                    state: state,
                    stars: store.progress(for: unit.id).stars,
                    side: index.isMultiple(of: 2) ? .leading : .trailing,
                    isLast: index == track.count - 1
                ) { handleTap(unit, state) }
            }
        }
        .padding(.horizontal, 24)
    }

    private func handleTap(_ unit: Unit, _ state: UnitNodeView.State) {
        switch state {
        case .premiumLocked:
            Haptics.shared.tap(); activeSheet = .unlock
        case .locked:
            Haptics.shared.tryAgain()
        case .done, .current, .available:
            Haptics.shared.tap(); activeUnit = unit
        }
    }

    private func nodeState(for unit: Unit) -> UnitNodeView.State {
        if store.isCompleted(unit.id) { return .done }
        if !entitlements.isSubscribed && Gating.isPremium(unit) { return .premiumLocked }
        if store.isUnlocked(unit) {
            return unit.id == store.nextUnit?.id ? .current : .available
        }
        return .locked
    }

    // MARK: Completion

    private var trackComplete: Bool {
        !track.isEmpty && store.completedCount == track.count
    }

    private var graduationBanner: some View {
        VStack(spacing: 12) {
            Image(systemName: "graduationcap.fill")
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 76, height: 76)
                .background(Circle().fill(store.tier.color))
                .shadow(color: store.tier.color.opacity(0.35), radius: 8, y: 4)
            Text("\(store.tier.name) Track Complete!")
                .sprocketFont(20, .heavy)
                .multilineTextAlignment(.center)
            Text("You've learned all Five Big Ideas. Amazing work, \(store.activeProfile?.name ?? "friend")!")
                .sprocketFont(14)
                .foregroundStyle(Theme.inkSoft)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Theme.ground2))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(store.tier.color.opacity(0.4), lineWidth: 2))
        .padding(.horizontal, 24)
    }
}
