import SwiftUI

struct SubscriptionView: View {
    @EnvironmentObject private var env: AppEnvironment
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            List {
                // Current plan section
                Section("Current Plan") {
                    HStack {
                        Label(env.isPremium ? "Premium" : "Free",
                              systemImage: env.isPremium ? "crown.fill" : "person.fill")
                            .foregroundStyle(env.isPremium ? .yellow : .secondary)
                        Spacer()
                        Text(env.isPremium ? "Active" : "Limited")
                            .font(.caption)
                            .foregroundStyle(env.isPremium ? .green : .secondary)
                    }
                }

                // Plan comparison
                Section("What's Included") {
                    featureRow("Try-ons per month",
                               free: "3",
                               premium: "Unlimited",
                               unlocked: env.isPremium)
                    featureRow("Save outfits",
                               free: "✗",
                               premium: "✓",
                               unlocked: env.isPremium)
                    featureRow("Outfit history",
                               free: "✗",
                               premium: "✓",
                               unlocked: env.isPremium)
                    featureRow("Priority new features",
                               free: "✗",
                               premium: "✓",
                               unlocked: env.isPremium)
                }

                if !env.isPremium {
                    Section {
                        Button("Upgrade to Premium") { showPaywall = true }
                            .buttonStyle(PrimaryButtonStyle())
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                }

                Section {
                    Button("Restore Purchases") {
                        Task { await env.storeKit.restorePurchases() }
                    }
                    .foregroundStyle(DSColor.accent)
                }

                if let error = env.storeKit.errorMessage {
                    Section {
                        ErrorStateView(message: error)
                    }
                }
            }
            .navigationTitle("Subscription")
            .sheet(isPresented: $showPaywall) {
                PaywallView().environmentObject(env)
            }
        }
    }

    private func featureRow(_ feature: String, free: String, premium: String, unlocked: Bool) -> some View {
        HStack {
            Text(feature).font(.subheadline)
            Spacer()
            Text(unlocked ? premium : free)
                .font(.subheadline)
                .foregroundStyle(unlocked ? .green : .secondary)
        }
    }
}
