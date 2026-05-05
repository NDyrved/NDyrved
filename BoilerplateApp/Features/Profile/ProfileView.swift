import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var env: AppEnvironment
    @State private var showSubscription = false
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            List {
                // Plan banner (long-press to toggle debug premium)
                Section {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle().fill(env.isPremium ? Color.yellow.opacity(0.15) : DSColor.card)
                                .frame(width: 52, height: 52)
                            Image(systemName: env.isPremium ? "crown.fill" : "person.fill")
                                .foregroundStyle(env.isPremium ? .yellow : .secondary)
                                .font(.title3)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(env.isPremium ? "Premium Member" : "Free Plan")
                                .font(.headline)
                            Text(env.isPremium
                                 ? (env.debugPremiumOverride ? "Debug mode — tap & hold to disable" : "Unlimited try-ons & saving")
                                 : "3 try-ons per month")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if !env.isPremium {
                            Button("Upgrade") { showPaywall = true }
                                .buttonStyle(.borderedProminent)
                                .tint(DSColor.accent)
                                .font(.caption.weight(.semibold))
                        }
                    }
                    .padding(.vertical, 4)
                    .onLongPressGesture {
                        env.toggleDebugPremium()
                    }
                }

                Section("Account") {
                    NavigationLink(destination: SubscriptionView().environmentObject(env)) {
                        Label("Subscription", systemImage: "creditcard")
                    }
                    NavigationLink(destination: SettingsView()) {
                        Label("Settings", systemImage: "gear")
                    }
                }

                Section("Legal") {
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                    NavigationLink(destination: TermsOfServiceView()) {
                        Label("Terms of Service", systemImage: "doc.text")
                    }
                }

                Section {
                    Button(role: .destructive) {
                        Task {
                            await env.authService.logout()
                            env.setAuthenticated(false)
                        }
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showPaywall) {
                PaywallView().environmentObject(env)
            }
        }
    }
}
