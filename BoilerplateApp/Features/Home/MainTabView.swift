import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView().tabItem { Label("Home", systemImage: "house") }
            ProfileView().tabItem { Label("Profile", systemImage: "person") }
            SettingsView().tabItem { Label("Settings", systemImage: "gear") }
        }
    }
}

struct HomeView: View {
    @EnvironmentObject private var env: AppEnvironment
    @State private var message: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if let message {
                    DSCard { Text(message) }
                } else {
                    LoadingView()
                }
                if env.featureFlags.isEnabled(.paywall) {
                    NavigationLink("Go to Paywall", destination: PaywallView())
                }
            }
            .padding()
            .task { if let welcome = try? await env.apiClient.fetchWelcome() { message = welcome.message } }
            .navigationTitle("Home")
        }
    }
}
