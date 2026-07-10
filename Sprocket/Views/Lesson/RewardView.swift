import SwiftUI

/// The celebration beat at the end of a unit: stars earned, XP gained, streak,
/// and any newly-unlocked badges. Warm and quick — a genuine "well done",
/// then straight back to the map to keep the momentum.
struct RewardView: View {
    let unit: Unit
    let stars: Int
    let badges: [Badge]
    let onDone: () -> Void

    @EnvironmentObject private var store: ProgressStore
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 22) {
            Spacer()

            MascotView(mood: .cheer, size: 104, tint: unit.tier.color)

            Text("Lesson Complete!")
                .sprocketFont(30, .heavy)
            Text(unit.title)
                .sprocketFont(17, .semibold)
                .foregroundStyle(unit.tier.color)

            starRow
                .scaleEffect(appeared ? 1 : 0.6)
                .opacity(appeared ? 1 : 0)

            HStack(spacing: 12) {
                rewardChip(icon: "bolt.fill", label: "+\(ProgressStore.xpPerUnit) XP", tint: Theme.spark)
                rewardChip(icon: "flame.fill",
                           label: "\(store.currentStreak)-day streak", tint: Theme.sprouts)
            }

            if !badges.isEmpty {
                VStack(spacing: 10) {
                    Text("New badge\(badges.count > 1 ? "s" : "")!")
                        .sprocketFont(14, .bold)
                        .foregroundStyle(Theme.inkSoft)
                    HStack(spacing: 14) {
                        ForEach(badges) { badge in badgeView(badge) }
                    }
                }
                .padding(.top, 4)
                .transition(.scale.combined(with: .opacity))
            }

            Spacer()

            Button("Keep Going") { Haptics.shared.tap(); onDone() }
                .buttonStyle(.sprocket(unit.tier.color))
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(unit.tier.softColor.opacity(0.6).ignoresSafeArea())
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.15)) {
                appeared = true
            }
        }
    }

    private var starRow: some View {
        HStack(spacing: 10) {
            ForEach(0..<3, id: \.self) { i in
                Image(systemName: i < stars ? "star.fill" : "star")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(i < stars ? Theme.sprouts : Theme.line)
            }
        }
    }

    private func rewardChip(icon: String, label: String, tint: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 14, weight: .bold))
            Text(label).sprocketFont(15, .bold)
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(Capsule().fill(Theme.ground2))
    }

    private func badgeView(_ badge: Badge) -> some View {
        VStack(spacing: 5) {
            Image(systemName: badge.symbol)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 58, height: 58)
                .background(Circle().fill(badge.color))
                .shadow(color: badge.color.opacity(0.4), radius: 6, y: 3)
            Text(badge.title)
                .sprocketFont(11, .semibold)
                .foregroundStyle(Theme.ink)
        }
    }
}
