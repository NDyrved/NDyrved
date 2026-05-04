import SwiftUI
import StoreKit

// MARK: - Updated product IDs
extension StoreKitProductID {
    // Override the product ID constants for this app
    static let premiumMonthlyV2 = "com.appname.monthly"
    static let premiumAnnualV2  = "com.appname.annual"
}

struct PaywallView: View {
    @EnvironmentObject private var env: AppEnvironment
    @StateObject private var vm: PaywallViewModel = .init(storeKit: .init())
    @Environment(\.dismiss) private var dismiss

    private let perks: [(icon: String, text: String)] = [
        ("infinity",                    "Unlimited try-ons"),
        ("sparkles",                    "AI wardrobe suggestions"),
        ("magnifyingglass",             "AI outfit discovery"),
        ("heart.fill",                  "Outfit saving & history"),
        ("building.2",                  "Store filtering & buy links"),
    ]

    var body: some View {
        ZStack(alignment: .top) {
            DSColor.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {

                    // Close button
                    HStack {
                        Spacer()
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(DSColor.textSecondary)
                                .padding(10)
                                .background(DSColor.surface, in: Circle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    // Trial hero
                    VStack(spacing: 10) {
                        Text("Try free for 3 days")
                            .font(DSTypography.display)
                            .foregroundStyle(DSColor.textPrimary)
                            .multilineTextAlignment(.center)
                        Text("cancel anytime")
                            .font(DSTypography.body)
                            .foregroundStyle(DSColor.textSecondary)

                        // Crown icon
                        ZStack {
                            Circle().fill(DSColor.accentMuted).frame(width: 80, height: 80)
                            Image(systemName: "crown.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(DSColor.accent)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)

                    // Perks
                    VStack(alignment: .leading, spacing: 14) {
                        ForEach(perks, id: \.text) { perk in
                            HStack(spacing: 14) {
                                Image(systemName: perk.icon)
                                    .foregroundStyle(DSColor.accent)
                                    .frame(width: 22)
                                Text(perk.text)
                                    .font(DSTypography.body)
                                    .foregroundStyle(DSColor.textPrimary)
                            }
                        }
                    }
                    .padding(20)
                    .background(DSColor.card, in: RoundedRectangle(cornerRadius: 18))
                    .padding(.horizontal, 20)

                    // Plan picker
                    VStack(spacing: 10) {
                        if vm.isLoading {
                            ProgressView("Loading plans…").padding()
                        } else {
                            // Annual — pre-selected
                            planCard(
                                id: StoreKitProductID.premiumAnnual,
                                title: "Annual",
                                price: vm.annualProduct?.displayPrice ?? "€199.99",
                                subtitle: "\(vm.annualMonthlyCost) / month",
                                savingsBadge: "Save \(vm.savingsPercent)%",
                                isPreferred: true
                            )
                            // Monthly
                            planCard(
                                id: StoreKitProductID.premiumMonthly,
                                title: "Monthly",
                                price: vm.monthlyProduct?.displayPrice ?? "€19.99",
                                subtitle: "Billed monthly",
                                savingsBadge: nil,
                                isPreferred: false
                            )
                        }
                    }
                    .padding(.horizontal, 20)

                    // Error
                    if let error = vm.errorMessage {
                        Text(error)
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColor.destructive)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }

                    // CTA block
                    VStack(spacing: 14) {
                        if vm.isPremium {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.seal.fill").foregroundStyle(DSColor.success)
                                Text("You're on Premium!").font(DSTypography.bodyMedium).foregroundStyle(DSColor.success)
                            }
                        } else {
                            Button {
                                Task { if await vm.subscribe() { dismiss() } }
                            } label: {
                                Group {
                                    if vm.isPurchasing { ProgressView().tint(.white) }
                                    else { Text("Start Free Trial") }
                                }.frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .disabled(vm.isPurchasing)

                            Button("Restore Purchases") {
                                Task { await vm.restore() }
                            }
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColor.textSecondary)

                            // Legal line
                            Text("No charge until trial ends · Cancel anytime")
                                .font(DSTypography.caption)
                                .foregroundStyle(DSColor.textTertiary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear { vm.selectedPlanID = StoreKitProductID.premiumAnnual }
    }

    // MARK: - Plan Card
    private func planCard(id: String, title: String, price: String,
                          subtitle: String, savingsBadge: String?, isPreferred: Bool) -> some View {
        let isSelected = vm.selectedPlanID == id
        return Button { vm.selectedPlanID = id } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(title).font(DSTypography.bodyMedium).foregroundStyle(DSColor.textPrimary)
                        if let badge = savingsBadge {
                            Text(badge)
                                .font(DSTypography.caption2)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8).padding(.vertical, 3)
                                .background(DSColor.accent, in: Capsule())
                        }
                    }
                    Text(subtitle).font(DSTypography.caption).foregroundStyle(DSColor.textSecondary)
                }
                Spacer()
                Text(price).font(DSTypography.bodyMedium).foregroundStyle(DSColor.textPrimary)
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? DSColor.accent : DSColor.border)
                    .font(.title3)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? DSColor.accentMuted : DSColor.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? DSColor.accent : DSColor.border, lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
