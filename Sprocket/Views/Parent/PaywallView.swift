import SwiftUI
import StoreKit

/// "Sprocket Plus" paywall. A grown-up surface — only ever reached through
/// the parent gate — so purchase controls are allowed here. Positioned as a
/// family plan (one price, every child, every track) to differentiate from
/// per-child competitors, and it states the privacy posture as part of the
/// pitch.
struct PaywallView: View {
    @EnvironmentObject private var entitlements: EntitlementStore
    @Environment(\.dismiss) private var dismiss

    @State private var selectedID: String?
    @State private var working = false

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                header
                valueList
                planList
                trialNote
                subscribeButton
                footer
                Color.clear.frame(height: 8)
            }
            .padding(20)
        }
        .background(Theme.ground.ignoresSafeArea())
        .overlay(alignment: .topTrailing) { closeButton }
        .onAppear { if selectedID == nil { selectedID = defaultSelection } }
        .onChange(of: entitlements.isSubscribed) { _, subscribed in
            if subscribed { dismiss() }
        }
    }

    // MARK: Header

    private var header: some View {
        VStack(spacing: 12) {
            MascotView(mood: .cheer, size: 84, tint: Theme.spark)
            Text("Sprocket Plus")
                .sprocketFont(30, .heavy)
            Text("Unlock every lesson, every track — for the whole family.")
                .sprocketFont(16)
                .foregroundStyle(Theme.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
        }
        .padding(.top, 24)
    }

    private var valueList: some View {
        VStack(alignment: .leading, spacing: 12) {
            valueRow("square.stack.3d.up.fill", "All three tracks", "Sprouts, Explorers & Builders — ages 5 to 17")
            valueRow("infinity", "Every lesson & mini-game", "The full AI curriculum, not just the intro")
            valueRow("person.2.fill", "Family Sharing", "One subscription covers all your kids")
            valueRow("lock.shield.fill", "Still private", "No ads, no tracking, no data sold — ever")
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Theme.ground2))
    }

    private func valueRow(_ icon: String, _ title: String, _ sub: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Theme.spark)
                .frame(width: 28, height: 28)
                .background(Circle().fill(Theme.spark.opacity(0.12)))
            VStack(alignment: .leading, spacing: 1) {
                Text(title).sprocketFont(15, .bold)
                Text(sub).sprocketFont(12).foregroundStyle(Theme.inkSoft)
            }
        }
    }

    // MARK: Plans

    private var planList: some View {
        VStack(spacing: 12) {
            ForEach(plans) { plan in planCard(plan) }
        }
    }

    private func planCard(_ plan: PlanVM) -> some View {
        let selected = selectedID == plan.id
        return Button {
            Haptics.shared.tap(); selectedID = plan.id
        } label: {
            HStack(spacing: 14) {
                Image(systemName: selected ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 22)).foregroundStyle(selected ? Theme.spark : Theme.line)
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(plan.title).sprocketFont(18, .bold)
                        if let tag = plan.tag {
                            Text(tag).sprocketFont(11, .bold).foregroundStyle(.white)
                                .padding(.horizontal, 8).padding(.vertical, 3)
                                .background(Capsule().fill(Theme.correct))
                        }
                    }
                    Text(plan.subtitle).sprocketFont(12).foregroundStyle(Theme.inkSoft)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 1) {
                    Text(plan.price).sprocketFont(18, .heavy)
                    Text(plan.cadence).sprocketFont(11).foregroundStyle(Theme.inkFaint)
                }
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Theme.ground2)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(selected ? Theme.spark : Theme.line, lineWidth: selected ? 2.5 : 1)
                    }
            }
        }
        .buttonStyle(.plain)
    }

    private var trialNote: some View {
        Group {
            if plans.contains(where: { $0.hasTrial }) {
                Label("Start with a free trial. Cancel anytime in Settings.",
                      systemImage: "gift.fill")
                    .sprocketFont(13, .medium)
                    .foregroundStyle(Theme.correct)
            }
        }
    }

    private var subscribeButton: some View {
        Button {
            Task { await subscribe() }
        } label: {
            if working { ProgressView().tint(.white) }
            else { Text(selectedPlan?.hasTrial == true ? "Start Free Trial" : "Subscribe") }
        }
        .buttonStyle(.sprocket)
        .disabled(working || selectedPlan == nil)
    }

    private var footer: some View {
        VStack(spacing: 10) {
            Button("Restore Purchases") { Task { await entitlements.restore() } }
                .sprocketFont(14, .semibold).foregroundStyle(Theme.inkSoft)
            Text("Payment is charged to your Apple Account. Subscriptions renew automatically until cancelled. Manage or cancel anytime in your device Settings.")
                .sprocketFont(11).foregroundStyle(Theme.inkFaint)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 4)
    }

    private var closeButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "xmark")
                .font(.system(size: 15, weight: .bold)).foregroundStyle(Theme.inkSoft)
                .frame(width: 34, height: 34).background(Circle().fill(Theme.ground3))
        }
        .padding(16)
        .accessibilityLabel("Close")
    }

    // MARK: Actions

    private func subscribe() async {
        guard let plan = selectedPlan else { return }
        working = true
        defer { working = false }
        if let product = plan.product {
            _ = await entitlements.purchase(product)
        } else {
            #if DEBUG
            entitlements.debugForceSubscribed = true   // no StoreKit config loaded — simulate for QA
            #endif
        }
    }

    // MARK: Plan view models (bridge StoreKit products → UI)

    private var plans: [PlanVM] {
        let live = entitlements.products.map { PlanVM(product: $0) }
        if !live.isEmpty { return live.sorted { ($0.sortWeight) < ($1.sortWeight) } }
        #if DEBUG
        return PlanVM.placeholders   // lets the paywall render without a StoreKit config in the simulator
        #else
        return []
        #endif
    }

    private var selectedPlan: PlanVM? { plans.first { $0.id == selectedID } }
    private var defaultSelection: String? {
        (plans.first { $0.tag != nil } ?? plans.first)?.id
    }
}

/// UI-facing plan model. Wraps a real `Product` when available; falls back to
/// static placeholders in DEBUG so the design is testable in the simulator
/// without an App Store Connect / StoreKit configuration loaded.
struct PlanVM: Identifiable {
    let id: String
    let title: String
    let price: String
    let cadence: String
    let subtitle: String
    let tag: String?
    let hasTrial: Bool
    let sortWeight: Int
    let product: Product?

    init(product: Product) {
        self.product = product
        self.id = product.id
        let annual = product.id == EntitlementStore.annualID
        self.title = annual ? "Annual" : "Monthly"
        self.price = product.displayPrice
        self.cadence = annual ? "per year" : "per month"
        self.subtitle = annual ? "Best value · Family Sharing" : "Family Sharing"
        self.tag = annual ? "SAVE" : nil
        self.hasTrial = product.subscription?.introductoryOffer?.paymentMode == .freeTrial
        self.sortWeight = annual ? 1 : 0
    }

    private init(id: String, title: String, price: String, cadence: String,
                 subtitle: String, tag: String?, hasTrial: Bool, sortWeight: Int) {
        self.id = id; self.title = title; self.price = price; self.cadence = cadence
        self.subtitle = subtitle; self.tag = tag; self.hasTrial = hasTrial
        self.sortWeight = sortWeight; self.product = nil
    }

    #if DEBUG
    static let placeholders: [PlanVM] = [
        PlanVM(id: EntitlementStore.monthlyID, title: "Monthly", price: "$6.99",
               cadence: "per month", subtitle: "Family Sharing", tag: nil,
               hasTrial: true, sortWeight: 0),
        PlanVM(id: EntitlementStore.annualID, title: "Annual", price: "$49.99",
               cadence: "per year", subtitle: "Best value · Family Sharing", tag: "SAVE",
               hasTrial: true, sortWeight: 1),
    ]
    #endif
}
