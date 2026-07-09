import SwiftUI

/// A "grown-ups only" check: a two-digit addition problem with regrouping,
/// harder than anything the app teaches a child, so it can't be brute-forced
/// from within the app itself. Gates onboarding setup, the parent dashboard,
/// and (later) any purchase or external link.
///
/// IMPORTANT: this is a distraction gate, NOT COPPA/GDPR verifiable parental
/// consent. It keeps a curious child out of grown-up controls; it does not,
/// on its own, authorize collecting a child's personal data. (See the
/// compliance brief — this distinction is the #1 trap in kids' apps.)
struct ParentGateView: View {
    let onPassed: () -> Void
    var onCancel: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @State private var a = Int.random(in: 23...58)
    @State private var b = Int.random(in: 14...49)
    @State private var choices: [Int] = []
    @State private var wrong = false

    private var answer: Int { a + b }

    var body: some View {
        VStack(spacing: 22) {
            Image(systemName: "person.badge.shield.checkmark.fill")
                .font(.system(size: 40))
                .foregroundStyle(Theme.spark)

            Text("Grown-Ups Only")
                .font(.sprocket(24, .heavy))

            Text("Please solve this to continue.")
                .font(.sprocket(16))
                .foregroundStyle(Theme.inkSoft)

            Text("\(a) + \(b) = ?")
                .font(.sprocket(38, .bold))
                .monospacedDigit()
                .padding(.vertical, 4)

            VStack(spacing: 12) {
                ForEach(choices, id: \.self) { choice in
                    Button {
                        if choice == answer { onPassed() }
                        else { wrong = true; Haptics.shared.tryAgain() }
                    } label: {
                        Text("\(choice)").monospacedDigit()
                    }
                    .buttonStyle(.sprocket(Theme.ink, filled: false))
                }
            }

            if wrong {
                Text("Not quite — try the math again.")
                    .font(.sprocket(14))
                    .foregroundStyle(Theme.gentle)
            }

            Button("Cancel") { (onCancel ?? { dismiss() })() }
                .font(.sprocket(16, .semibold))
                .foregroundStyle(Theme.inkSoft)
                .padding(.top, 4)
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.ground)
        .onAppear(perform: setUp)
    }

    private func setUp() {
        var options: Set<Int> = [answer]
        while options.count < 4 {
            options.insert(answer + Int.random(in: -14...14))
        }
        choices = Array(options).shuffled()
    }
}
