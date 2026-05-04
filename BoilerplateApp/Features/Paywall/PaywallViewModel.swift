import Foundation
import StoreKit

@MainActor
final class PaywallViewModel: ObservableObject {
    @Published var selectedPlanID = StoreKitProductID.premiumAnnual
    @Published var isPurchasing = false
    @Published var errorMessage: String?

    private let storeKit: StoreKitService

    init(storeKit: StoreKitService) {
        self.storeKit = storeKit
    }

    var isPremium: Bool { storeKit.tier == .premium }
    var isLoading: Bool { storeKit.isLoading }
    var monthlyProduct: Product? { storeKit.monthlyProduct }
    var annualProduct: Product?  { storeKit.annualProduct }

    var annualMonthlyCost: String {
        guard let product = annualProduct else { return "€16.67" }
        let monthly = product.price / 12
        let fmt = NumberFormatter()
        fmt.numberStyle = .currency
        fmt.locale = product.priceFormatStyle.locale
        return fmt.string(from: NSDecimalNumber(decimal: monthly)) ?? "€16.67"
    }

    var savingsPercent: Int {
        guard let monthly = monthlyProduct, let annual = annualProduct else { return 17 }
        let monthlyAnnual = monthly.price * 12
        let saving = (monthlyAnnual - annual.price) / monthlyAnnual * 100
        return Int(truncating: saving as NSDecimalNumber)
    }

    func subscribe() async -> Bool {
        guard let product = selectedPlanID == StoreKitProductID.premiumAnnual
                ? annualProduct : monthlyProduct
        else { return false }

        isPurchasing = true
        errorMessage = nil
        do {
            let success = try await storeKit.purchase(product)
            isPurchasing = false
            return success
        } catch {
            errorMessage = error.localizedDescription
            isPurchasing = false
            return false
        }
    }

    func restore() async {
        await storeKit.restorePurchases()
    }
}
