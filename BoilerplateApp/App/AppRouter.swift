import SwiftUI

enum AppRoute: Hashable {
    case onboarding
    case login
    case register
    case tabs
    case paywall
    case privacy
    case terms
}

struct AppRootView: View {
    @EnvironmentObject private var env: AppEnvironment

    var body: some View {
        NavigationStack {
            if !env.appState.isOnboardingComplete {
                OnboardingView()
            } else if !env.appState.isAuthenticated {
                LoginView()
            } else {
                MainTabView()
            }
        }
        .tint(DSColor.accent)
    }
}
