import SwiftUI

/// Retrieval practice. Questions the child has already met come back on a
/// widening schedule; answering them from memory is what actually builds
/// durable knowledge, far more than re-reading the lesson would.
///
/// Reuses `QuizView` verbatim so a review feels exactly like a lesson quiz —
/// same gentleness, same explanation on a miss, nothing punitive. A wrong
/// answer simply means the question returns tomorrow.
struct ReviewSessionView: View {
    @EnvironmentObject private var store: ProgressStore
    @Environment(\.dismiss) private var dismiss

    @State private var queue: [ReviewItem] = []
    @State private var index = 0
    @State private var correctCount = 0
    @State private var finished = false

    private var tint: Color { store.tier.color }

    var body: some View {
        ZStack {
            Theme.ground.ignoresSafeArea()

            if finished || queue.isEmpty {
                summary
            } else {
                VStack(spacing: 0) {
                    topBar
                    currentQuestion
                        .id(index)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.28), value: index)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: finished)
        .onAppear(perform: loadQueue)
    }

    /// Drop any item whose question no longer resolves (content moved under it)
    /// rather than showing a blank screen.
    private func loadQueue() {
        guard queue.isEmpty else { return }
        let due = store.dueReviews
        let resolvable = due.filter { Curriculum.question(for: $0) != nil }
        let stale = due.filter { Curriculum.question(for: $0) == nil }
        for item in stale { store.reviewItems.removeValue(forKey: item.id) }
        queue = resolvable
    }

    private var topBar: some View {
        HStack(spacing: 14) {
            Button {
                Haptics.shared.tap(); SpeechService.shared.stop(); dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Theme.inkSoft)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Theme.ground3))
            }
            .accessibilityLabel("Close practice")

            ProgressView(value: Double(index), total: Double(max(1, queue.count)))
                .tint(tint)

            Text("\(index + 1)/\(queue.count)")
                .sprocketFont(13, .bold).monospacedDigit()
                .foregroundStyle(Theme.inkFaint)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private var currentQuestion: some View {
        let item = queue[index]
        if let question = Curriculum.question(for: item) {
            QuizView(
                question: question,
                tint: Curriculum.tier(for: item)?.color ?? tint,
                onResult: { correct in
                    store.recordReview(item, correct: correct)
                    if correct { correctCount += 1 }
                },
                onNext: advance)
        } else {
            Color.clear.onAppear(perform: advance)   // defensive: stale entry
        }
    }

    private func advance() {
        SpeechService.shared.stop()
        if index + 1 < queue.count {
            index += 1
        } else {
            store.recordReviewSessionFinished()
            Haptics.shared.win()
            finished = true
        }
    }

    // MARK: Summary

    private var summary: some View {
        VStack(spacing: 20) {
            Spacer()
            MascotView(mood: .cheer, size: 100, tint: tint)

            if queue.isEmpty {
                Text("All caught up!").sprocketFont(28, .heavy)
                Text("Nothing to practise right now. Finish a lesson and it'll come back here later.")
                    .sprocketFont(16).foregroundStyle(Theme.inkSoft)
                    .multilineTextAlignment(.center).padding(.horizontal, 32)
            } else {
                Text("Practice done!").sprocketFont(30, .heavy)
                Text("\(correctCount) of \(queue.count) remembered")
                    .sprocketFont(17, .semibold).foregroundStyle(tint)
                Text("Remembering something is what makes it stick. The tricky ones will come back sooner.")
                    .sprocketFont(14).foregroundStyle(Theme.inkSoft)
                    .multilineTextAlignment(.center).padding(.horizontal, 32)

                if correctCount > 0 {
                    Label("+\(correctCount * ProgressStore.xpPerReview) XP", systemImage: "bolt.fill")
                        .sprocketFont(15, .bold).foregroundStyle(Theme.spark)
                        .padding(.horizontal, 14).padding(.vertical, 9)
                        .background(Capsule().fill(Theme.ground2))
                }
            }

            Spacer()
            Button("Done") { Haptics.shared.tap(); dismiss() }
                .buttonStyle(.sprocket(tint))
                .padding(.horizontal, 24).padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
