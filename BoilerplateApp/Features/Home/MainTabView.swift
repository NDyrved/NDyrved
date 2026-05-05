import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var env: AppEnvironment
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeHubView(selectedTab: $selectedTab)
                .tabItem { Label("Home",     systemImage: "house") }
                .tag(0)

            DiscoveryView()
                .tabItem { Label("Search",   systemImage: "magnifyingglass") }
                .tag(1)

            TryOnView()
                .tabItem { Label("Builder",  systemImage: "hanger") }
                .tag(2)

            WardrobeView()
                .tabItem { Label("Wardrobe", systemImage: "tshirt") }
                .tag(3)

            ProfileView()
                .tabItem { Label("Profile",  systemImage: "person") }
                .tag(4)
        }
        .tint(DSColor.accent)
    }
}

// MARK: - Home Hub
/// Landing screen — entry point into the app's core actions.
struct HomeHubView: View {
    @EnvironmentObject private var env: AppEnvironment
    @Binding var selectedTab: Int

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {

                    // Hero
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Mirra")
                            .font(DSTypography.display)
                            .foregroundStyle(DSColor.accent)
                        Text("Your Virtual Fitting Room")
                            .font(DSTypography.title2)
                            .foregroundStyle(DSColor.textSecondary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                    // Quick actions
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Get Started")
                            .font(DSTypography.label)
                            .foregroundStyle(DSColor.textSecondary)
                            .padding(.horizontal, 24)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                QuickActionCard(icon: "hanger",
                                                title: "Try On",
                                                subtitle: "Build an outfit") {
                                    selectedTab = 2   // Builder tab
                                }
                                QuickActionCard(icon: "magnifyingglass",
                                                title: "Discover",
                                                subtitle: "Shop curated looks") {
                                    selectedTab = 1   // Search tab
                                }
                                QuickActionCard(icon: "tshirt",
                                                title: "My Wardrobe",
                                                subtitle: "\(env.outfitStore.outfits.count) saved outfits") {
                                    selectedTab = 3   // Wardrobe tab
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }

                    // Plan status
                    DSCard {
                        HStack(spacing: 14) {
                            Image(systemName: env.isPremium ? "crown.fill" : "sparkles")
                                .font(.title2)
                                .foregroundStyle(env.isPremium ? .yellow : DSColor.accent)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(env.isPremium ? "Premium Active" : "Free Plan")
                                    .font(DSTypography.bodyMedium)
                                    .foregroundStyle(DSColor.textPrimary)
                                Text(env.isPremium
                                     ? "Unlimited try-ons & AI suggestions"
                                     : "\(max(0, 3 - env.outfitStore.tryOnCountThisMonth)) try-ons remaining this month")
                                    .font(DSTypography.caption)
                                    .foregroundStyle(DSColor.textSecondary)
                            }
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 32)
            }
            .background(DSColor.background)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Quick Action Card
private struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(DSColor.accent)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(DSTypography.title3)
                        .foregroundStyle(DSColor.textPrimary)
                    Text(subtitle)
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColor.textSecondary)
                }
            }
            .padding(18)
            .frame(width: 150)
            .background(DSColor.card)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}
