import SwiftUI

/// A kid-facing "trophy room" — every badge laid out, earned ones bright and
/// still-locked ones shown as quiet silhouettes with a hint for how to earn
/// them. This is the "collect them all" surface the reward moment points
/// toward; no gate, it's the child's own shelf of accomplishments.
struct TrophyRoomView: View {
    @EnvironmentObject private var store: ProgressStore
    @Environment(\.dismiss) private var dismiss

    private var tint: Color { store.tier.color }
    private var earnedCount: Int { store.badges.count }

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 14)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    summary
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(Badge.allCases) { badge in
                            badgeTile(badge, earned: store.earnedBadges.contains(badge.rawValue))
                        }
                    }
                    Color.clear.frame(height: 8)
                }
                .padding(20)
            }
            .background(Theme.ground.ignoresSafeArea())
            .navigationTitle("My Trophies")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }.sprocketFont(16, .bold)
                }
            }
        }
    }

    private var summary: some View {
        HStack(spacing: 14) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Circle().fill(tint))
                .shadow(color: tint.opacity(0.35), radius: 6, y: 3)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(earnedCount) of \(Badge.allCases.count) badges")
                    .sprocketFont(20, .heavy)
                Text(earnedCount == Badge.allCases.count
                     ? "You collected them all! Wow!"
                     : "Keep learning to earn them all!")
                    .sprocketFont(13).foregroundStyle(Theme.inkSoft)
            }
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Theme.ground2))
    }

    private func badgeTile(_ badge: Badge, earned: Bool) -> some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(earned ? badge.color : Theme.ground3)
                    .frame(width: 72, height: 72)
                    .shadow(color: earned ? badge.color.opacity(0.35) : .clear, radius: 6, y: 3)
                Image(systemName: earned ? badge.symbol : "lock.fill")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(earned ? .white : Theme.inkFaint)
            }
            VStack(spacing: 3) {
                Text(badge.title)
                    .sprocketFont(15, .bold)
                    .foregroundStyle(earned ? Theme.ink : Theme.inkFaint)
                Text(badge.blurb)
                    .sprocketFont(11)
                    .foregroundStyle(Theme.inkFaint)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Theme.ground2)
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(earned ? badge.color.opacity(0.4) : Theme.line, lineWidth: 1.5)
                }
        }
    }
}
