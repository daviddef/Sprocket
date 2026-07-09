import SwiftUI

/// The home screen and the one surface worth entering at: a vertical "path"
/// of unit nodes the child climbs, with a compact stats header (XP + streak)
/// and a grown-up gate into the parent area. Tapping an unlocked node opens
/// the lesson player.
struct HomeView: View {
    @EnvironmentObject private var store: ProgressStore

    @State private var activeUnit: Unit?
    @State private var showGate = false
    @State private var showParent = false

    private var track: [Unit] { store.track }

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
        .sheet(isPresented: $showGate) {
            ParentGateView(onPassed: { showGate = false; showParent = true },
                           onCancel: { showGate = false })
        }
        .sheet(isPresented: $showParent) {
            ParentDashboardView()
        }
        .onAppear { Haptics.shared.prepareAll() }
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting)
                    .font(.sprocket(22, .heavy))
                    .foregroundStyle(Theme.ink)
                Text(store.tier.name + " · " + store.tier.ageRange)
                    .font(.sprocket(13, .semibold))
                    .foregroundStyle(store.tier.color)
            }
            Spacer()
            statChip(icon: "bolt.fill", value: "\(store.xp)", tint: Theme.spark)
            statChip(icon: "flame.fill", value: "\(store.currentStreak)", tint: Theme.sprouts)
            Button {
                Haptics.shared.tap(); showGate = true
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
            Text(value).font(.sprocket(15, .bold)).monospacedDigit()
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
                UnitNodeView(
                    unit: unit,
                    state: nodeState(for: unit),
                    stars: store.progress(for: unit.id).stars,
                    side: index.isMultiple(of: 2) ? .leading : .trailing,
                    isLast: index == track.count - 1
                ) {
                    guard store.isUnlocked(unit) else { Haptics.shared.tryAgain(); return }
                    Haptics.shared.tap()
                    activeUnit = unit
                }
            }
        }
        .padding(.horizontal, 24)
    }

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
                .font(.sprocket(20, .heavy))
                .multilineTextAlignment(.center)
            Text("You've learned all Five Big Ideas. Amazing work, \(store.activeProfile?.name ?? "friend")!")
                .font(.sprocket(14))
                .foregroundStyle(Theme.inkSoft)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Theme.ground2))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(store.tier.color.opacity(0.4), lineWidth: 2))
        .padding(.horizontal, 24)
    }

    private func nodeState(for unit: Unit) -> UnitNodeView.State {
        if store.isCompleted(unit.id) { return .done }
        if store.isUnlocked(unit) {
            return unit.id == store.nextUnit?.id ? .current : .available
        }
        return .locked
    }
}
