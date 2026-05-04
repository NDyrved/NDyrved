import SwiftUI

enum AppRoute: Hashable {
    case onboarding
    case login
    case tabs
    case paywall
    case privacy
    case terms
    case tryon
    case outfitBuilder(Outfit)
    case savedOutfits
    case subscription
}

struct AppRootView: View {
    @EnvironmentObject private var env: AppEnvironment

    var body: some View {
        NavigationStack {
            if !env.appState.isOnboardingComplete {
                OnboardingView()
            } else if !env.appState.isAuthenticated {
                AuthView()
            } else {
                MainTabView()
            }
        }
        .tint(DSColor.accent)
    }
}
