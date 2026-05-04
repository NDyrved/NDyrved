import Foundation
import StoreKit

// MARK: - Product IDs
// Configure these in App Store Connect under your app's In-App Purchases.
enum StoreKitProductID {
    static let premiumMonthly = "com.ndyrved.outfitapp.premium.monthly"
    static let premiumAnnual  = "com.ndyrved.outfitapp.premium.annual"

    static let all: [String] = [premiumMonthly, premiumAnnual]
}

// MARK: - Subscription Tier
enum SubscriptionTier: Equatable {
    case free
    case premium

    var monthlyTryOnLimit: Int { self == .free ? 3 : Int.max }
    var canSaveOutfits: Bool { self == .premium }
    var canViewHistory: Bool { self == .premium }
}

// MARK: - StoreKit Service
@MainActor
final class StoreKitService: ObservableObject {
    @Published var products: [Product] = []
    @Published var tier: SubscriptionTier = .free
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var transactionListener: Task<Void, Error>?

    init() {
        transactionListener = listenForTransactions()
        Task { await loadProducts() }
        Task { await refreshSubscriptionStatus() }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: Load Products
    func loadProducts() async {
        isLoading = true
        do {
            products = try await Product.products(for: StoreKitProductID.all)
                .sorted { $0.price < $1.price }
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
        }
        isLoading = false
    }

    // MARK: Purchase
    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await refreshSubscriptionStatus()
            return true
        case .userCancelled:
            return false
        case .pending:
            return false
        @unknown default:
            return false
        }
    }

    // MARK: Restore
    func restorePurchases() async {
        isLoading = true
        do {
            try await AppStore.sync()
            await refreshSubscriptionStatus()
        } catch {
            errorMessage = "Restore failed: \(error.localizedDescription)"
        }
        isLoading = false
    }

    // MARK: Refresh Status
    func refreshSubscriptionStatus() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.revocationDate == nil,
               StoreKitProductID.all.contains(transaction.productID) {
                tier = .premium
                return
            }
        }
        tier = .free
    }

    // MARK: Listen for Transactions
    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.refreshSubscriptionStatus()
                    await transaction.finish()
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }

    private nonisolated func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error): throw error
        case .verified(let safe): return safe
        }
    }

    // MARK: Helpers
    var monthlyProduct: Product? { products.first { $0.id == StoreKitProductID.premiumMonthly } }
    var annualProduct: Product?  { products.first { $0.id == StoreKitProductID.premiumAnnual  } }

    func formattedPrice(for product: Product) -> String { product.displayPrice }
}
