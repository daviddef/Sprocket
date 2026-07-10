import SwiftUI

/// "Who's learning?" — the kid-facing switcher between siblings on a shared
/// device. Deliberately *not* behind the parent gate: swapping to your own
/// profile isn't a sensitive action, and making a 6-year-old fetch a grown-up
/// to start their lesson would be absurd. Adding and removing children stays
/// in the grown-up area.
struct ProfilePickerView: View {
    @EnvironmentObject private var store: ProgressStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(store.profiles) { profile in
                        row(profile)
                    }
                    Label("A grown-up can add or remove children.",
                          systemImage: "person.badge.shield.checkmark")
                        .font(.sprocket(12))
                        .foregroundStyle(Theme.inkFaint)
                        .padding(.top, 8)
                }
                .padding(20)
            }
            .background(Theme.ground.ignoresSafeArea())
            .navigationTitle("Who's learning?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }.font(.sprocket(16, .bold))
                }
            }
        }
    }

    private func row(_ profile: LearnerProfile) -> some View {
        let active = profile.id == store.activeProfileID
        let done = store.completedCount(for: profile)
        let total = Curriculum.track(for: profile.tier).count

        return Button {
            Haptics.shared.tap()
            store.switchTo(profile.id)
            dismiss()
        } label: {
            HStack(spacing: 14) {
                Text(initial(profile.name))
                    .font(.sprocket(24, .heavy))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(Circle().fill(profile.tier.color))

                VStack(alignment: .leading, spacing: 2) {
                    Text(profile.name).font(.sprocket(19, .bold)).foregroundStyle(Theme.ink)
                    Text("\(profile.tier.name) · \(profile.tier.ageRange)")
                        .font(.sprocket(12, .semibold)).foregroundStyle(profile.tier.color)
                    Text("\(done) of \(total) lessons · \(store.xp(for: profile)) XP")
                        .font(.sprocket(12)).foregroundStyle(Theme.inkFaint)
                }
                Spacer()
                if active {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(profile.tier.color)
                }
            }
            .padding(14)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Theme.ground2)
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(active ? profile.tier.color : Theme.line,
                                          lineWidth: active ? 2.5 : 1)
                    }
            }
        }
        .buttonStyle(.plain)
    }

    private func initial(_ name: String) -> String {
        String(name.trimmingCharacters(in: .whitespaces).first.map(String.init) ?? "?").uppercased()
    }
}
