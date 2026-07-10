import SwiftUI

/// Two phases. First the child picks which examples to train on; then the
/// model is tested on data it has never seen, and its accuracy is a direct
/// consequence of what they chose.
///
/// This is the only game where the child's decisions cause the outcome, which
/// is the whole point: "garbage in, garbage out" lands far harder when it's
/// *your* garbage.
struct TrainAndTestView: View {
    let game: TrainAndTestGame
    var tint: Color = Theme.spark
    let onNext: () -> Void

    private enum Phase { case choosing, results }
    @State private var phase: Phase = .choosing
    @State private var chosen: Set<UUID> = []

    private var chosenExamples: [TrainAndTestGame.Example] {
        game.pool.filter { chosen.contains($0.id) }
    }
    private var goodCount: Int { chosenExamples.filter(\.isGood).count }
    /// Every clean example the child picked earns one correct test answer.
    private var testsPassed: Int {
        guard game.pickCount > 0 else { return 0 }
        let ratio = Double(goodCount) / Double(game.pickCount)
        return Int((ratio * Double(game.tests.count)).rounded())
    }
    private var accuracy: Int {
        game.tests.isEmpty ? 0 : Int((Double(testsPassed) / Double(game.tests.count) * 100).rounded())
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                header
                if phase == .choosing { choosingPhase } else { resultsPhase }
                Color.clear.frame(height: 12)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: phase)
        .animation(.easeInOut(duration: 0.2), value: chosen)
        #if DEBUG
        // QA: SPROCKET_DEBUG_AUTOPICK=1 trains on a deliberately mixed set
        // (some good, some bad) so the results phase can be screenshotted.
        .onAppear {
            if ProcessInfo.processInfo.environment["SPROCKET_DEBUG_AUTOPICK"] == "1" {
                let good = game.pool.filter(\.isGood).prefix(max(1, game.pickCount - 1))
                let bad  = game.pool.filter { !$0.isGood }.prefix(1)
                chosen = Set((good + bad).map(\.id))
                phase = .results
            }
        }
        #endif
    }

    private var header: some View {
        VStack(spacing: 8) {
            Label("Train & Test", systemImage: "brain.head.profile")
                .sprocketFont(21, .heavy).foregroundStyle(Theme.ink)
            Text(phase == .choosing ? game.intro : "Now let's see how it does on pictures it has never seen.")
                .sprocketFont(14).foregroundStyle(Theme.inkSoft)
                .multilineTextAlignment(.center)
            HStack(spacing: 8) {
                Image(systemName: "target").foregroundStyle(tint)
                Text(game.goal).sprocketFont(14, .semibold).foregroundStyle(Theme.ink)
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 14).fill(tint.opacity(0.10)))
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    // MARK: Phase 1 — choose training data

    private var choosingPhase: some View {
        VStack(spacing: 14) {
            Text("Pick \(game.pickCount) examples to train on  (\(chosen.count)/\(game.pickCount))")
                .sprocketFont(13, .bold).foregroundStyle(Theme.inkFaint)

            VStack(spacing: 10) {
                ForEach(game.pool) { example in
                    exampleRow(example)
                }
            }
            .padding(.horizontal, 20)

            Button("Train the Model") {
                Haptics.shared.win(); phase = .results
            }
            .buttonStyle(.sprocket(tint))
            .disabled(chosen.count != game.pickCount)
            .opacity(chosen.count == game.pickCount ? 1 : 0.5)
            .padding(.horizontal, 20)
            .padding(.top, 4)
        }
    }

    private func exampleRow(_ example: TrainAndTestGame.Example) -> some View {
        let isChosen = chosen.contains(example.id)
        let full = chosen.count >= game.pickCount && !isChosen
        return Button {
            Haptics.shared.tap()
            if isChosen { chosen.remove(example.id) }
            else if chosen.count < game.pickCount { chosen.insert(example.id) }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: example.symbol)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(isChosen ? .white : tint)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(isChosen ? tint : tint.opacity(0.12)))
                Text(example.label)
                    .sprocketFont(15, .semibold).foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 4)
                Image(systemName: isChosen ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(isChosen ? tint : Theme.line)
            }
            .padding(12)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Theme.ground2)
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(isChosen ? tint : Theme.line, lineWidth: isChosen ? 2.5 : 1)
                    }
            }
            .opacity(full ? 0.45 : 1)
        }
        .buttonStyle(.plain)
        .disabled(full)
    }

    // MARK: Phase 2 — results

    private var resultsPhase: some View {
        VStack(spacing: 16) {
            scoreCard

            VStack(alignment: .leading, spacing: 10) {
                Text("Test results").sprocketFont(14, .bold).foregroundStyle(Theme.inkFaint)
                ForEach(Array(game.tests.enumerated()), id: \.element.id) { i, test in
                    testRow(test, passed: i < testsPassed)
                }
            }
            .padding(.horizontal, 20)

            VStack(alignment: .leading, spacing: 10) {
                Text("What you trained it on").sprocketFont(14, .bold).foregroundStyle(Theme.inkFaint)
                ForEach(chosenExamples) { example in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: example.isGood ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundStyle(example.isGood ? Theme.correct : Theme.gentle)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(example.label).sprocketFont(14, .semibold).foregroundStyle(Theme.ink)
                            Text(example.why).sprocketFont(12).foregroundStyle(Theme.inkSoft)
                        }
                        Spacer(minLength: 0)
                    }
                }
            }
            .padding(.horizontal, 20)

            VStack(spacing: 10) {
                Button("Next") { Haptics.shared.tap(); onNext() }
                    .buttonStyle(.sprocket(tint))
                Button("Try Different Data") {
                    Haptics.shared.tap(); chosen = []; phase = .choosing
                }
                .buttonStyle(.sprocket(tint, filled: false))
            }
            .padding(.horizontal, 20)
        }
    }

    private var scoreCard: some View {
        VStack(spacing: 6) {
            Text("\(accuracy)%")
                .sprocketFont(46, .heavy).monospacedDigit()
                .foregroundStyle(accuracy >= 100 ? Theme.correct : (accuracy >= 50 ? Theme.gentle : Theme.spark))
            Text("accuracy on new pictures")
                .sprocketFont(13).foregroundStyle(Theme.inkFaint)
            Text(verdict)
                .sprocketFont(14, .semibold)
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Theme.ground2))
        .padding(.horizontal, 20)
    }

    private var verdict: String {
        switch accuracy {
        case 100:   return "Clean, varied examples — the model learned well!"
        case 50...: return "Some of your examples confused it. Mixed results."
        default:    return "Bad training data taught it the wrong thing."
        }
    }

    private func testRow(_ test: TrainAndTestGame.TestCase, passed: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: test.symbol)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Theme.inkSoft)
                .frame(width: 38, height: 38)
                .background(Circle().fill(Theme.ground3))
            Text(test.label).sprocketFont(14, .semibold).foregroundStyle(Theme.ink)
            Spacer(minLength: 4)
            Label(passed ? "Correct" : "Wrong", systemImage: passed ? "checkmark" : "xmark")
                .sprocketFont(12, .bold)
                .foregroundStyle(passed ? Theme.correct : Theme.gentle)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 12).fill(
            (passed ? Theme.correctBG : Theme.gentleBG).opacity(0.5)))
    }
}
