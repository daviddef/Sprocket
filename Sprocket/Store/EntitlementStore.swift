import StoreKit

/// Owns the subscription state for "Sprocket Plus". StoreKit 2: loads the
/// products, listens for transaction updates, and derives a single
/// `isSubscribed` flag the rest of the app gates on. One shared instance,
/// injected at the app root.
///
/// Kids Category note: nothing here is ever shown to a child directly — the
/// paywall it backs is reachable only through the parent gate. A child sees a
/// gentle "ask a grown-up" prompt, never a purchase button.
@MainActor
final class EntitlementStore: ObservableObject {
    static let shared = EntitlementStore()

    static let monthlyID = "com.daviddefranceski.sprocket.monthly"
    static let annualID  = "com.daviddefranceski.sprocket.annual"
    private let productIDs = [monthlyID, annualID]

    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedIDs: Set<String> = []
    @Published var debugForceSubscribed = false

    private var updatesTask: Task<Void, Never>?

    /// The one flag the app gates content on.
    var isSubscribed: Bool { debugForceSubscribed || !purchasedIDs.isEmpty }

    private init() {
        #if DEBUG
        if ProcessInfo.processInfo.environment["SPROCKET_DEBUG_PLUS"] == "1" {
            debugForceSubscribed = true
        }
        #endif
        updatesTask = listenForTransactions()
        Task { await loadProducts(); await refreshEntitlements() }
    }

    // MARK: - Products

    func loadProducts() async {
        do {
            let items = try await Product.products(for: productIDs)
            products = items.sorted { $0.price < $1.price }
        } catch {
            products = []
        }
    }

    var monthly: Product? { products.first { $0.id == Self.monthlyID } }
    var annual: Product?  { products.first { $0.id == Self.annualID } }

    // MARK: - Purchase / restore

    @discardableResult
    func purchase(_ product: Product) async -> Bool {
        do {
            switch try await product.purchase() {
            case .success(let verification):
                guard case .verified(let transaction) = verification else { return false }
                await transaction.finish()
                await refreshEntitlements()
                return true
            case .userCancelled, .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            return false
        }
    }

    func restore() async {
        try? await AppStore.sync()
        await refreshEntitlements()
    }

    // MARK: - Entitlements

    func refreshEntitlements() async {
        var active = Set<String>()
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if transaction.revocationDate == nil {
                active.insert(transaction.productID)
            }
        }
        purchasedIDs = active
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                }
                await self?.refreshEntitlements()
            }
        }
    }
}
