import SwiftUI

/// First-run setup. The tier (age track) is a grown-up's choice, so the flow
/// is: welcome → grown-up gate → pick a track → optional child name → start.
/// Once a profile is created, RootView swaps this out for the home map.
struct OnboardingView: View {
    @EnvironmentObject private var store: ProgressStore

    private enum Stage { case welcome, pickTier, name }
    @State private var stage: Stage = .welcome
    @State private var showGate = false
    @State private var chosenTier: Tier = .explorers
    @State private var childName = ""

    var body: some View {
        ZStack {
            Theme.ground.ignoresSafeArea()
            switch stage {
            case .welcome:  welcome
            case .pickTier: tierPicker
            case .name:     nameEntry
            }
        }
        .animation(.easeInOut(duration: 0.3), value: stage)
        .sheet(isPresented: $showGate) {
            ParentGateView(onPassed: {
                showGate = false
                stage = .pickTier
            }, onCancel: { showGate = false })
        }
    }

    // MARK: Welcome

    private var welcome: some View {
        VStack(spacing: 24) {
            Spacer()
            MascotView(mood: .happy, size: 120)
            VStack(spacing: 10) {
                Text("Meet Sprocket")
                    .font(.sprocket(40, .heavy))
                Text("A fun, friendly way to learn what AI is — and how to use it wisely.")
                    .font(.sprocket(18))
                    .foregroundStyle(Theme.inkSoft)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            Spacer()
            VStack(spacing: 12) {
                Button("Get Started") { showGate = true }
                    .buttonStyle(.sprocket)
                Label("Setup is for grown-ups", systemImage: "person.badge.shield.checkmark")
                    .font(.sprocket(13))
                    .foregroundStyle(Theme.inkFaint)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 24)
        }
    }

    // MARK: Tier picker

    private var tierPicker: some View {
        VStack(spacing: 18) {
            VStack(spacing: 6) {
                Text("Choose a track")
                    .font(.sprocket(28, .heavy))
                Text("Pick the one that fits your child's age. You can change it later.")
                    .font(.sprocket(15))
                    .foregroundStyle(Theme.inkSoft)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            .padding(.horizontal, 24)

            ScrollView {
                VStack(spacing: 14) {
                    ForEach(Tier.allCases) { tier in
                        tierCard(tier)
                    }
                }
                .padding(20)
            }

            Button("Continue") { stage = .name }
                .buttonStyle(.sprocket(chosenTier.color))
                .padding(.horizontal, 28)
                .padding(.bottom, 24)
        }
    }

    private func tierCard(_ tier: Tier) -> some View {
        let selected = chosenTier == tier
        return Button {
            Haptics.shared.tap()
            chosenTier = tier
        } label: {
            HStack(spacing: 16) {
                Image(systemName: tier.symbol)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(tier.color)
                    .frame(width: 54, height: 54)
                    .background(Circle().fill(tier.softColor))
                VStack(alignment: .leading, spacing: 3) {
                    Text(tier.name).font(.sprocket(20, .bold)).foregroundStyle(Theme.ink)
                    Text(tier.ageRange).font(.sprocket(14, .semibold)).foregroundStyle(tier.color)
                    Text(tier.tagline).font(.sprocket(13)).foregroundStyle(Theme.inkSoft)
                }
                Spacer()
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundStyle(selected ? tier.color : Theme.line)
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Theme.ground2)
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(selected ? tier.color : Theme.line, lineWidth: selected ? 2.5 : 1)
                    }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: Name

    private var nameEntry: some View {
        VStack(spacing: 22) {
            Spacer()
            MascotView(mood: .cheer, size: 100, tint: chosenTier.color)
            Text("What should I call you?")
                .font(.sprocket(26, .heavy))
                .multilineTextAlignment(.center)
            Text("First name or a nickname — totally optional.")
                .font(.sprocket(15))
                .foregroundStyle(Theme.inkSoft)

            TextField("Explorer", text: $childName)
                .font(.sprocket(20, .semibold))
                .multilineTextAlignment(.center)
                .textInputAutocapitalization(.words)
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 14).fill(Theme.ground2))
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Theme.line))
                .padding(.horizontal, 40)

            Spacer()
            Button("Start Learning") {
                store.createProfile(name: childName.trimmingCharacters(in: .whitespaces), tier: chosenTier)
            }
            .buttonStyle(.sprocket(chosenTier.color))
            .padding(.horizontal, 28)
            .padding(.bottom, 24)
        }
    }
}
