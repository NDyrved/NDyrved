import SwiftUI

@MainActor
final class AppEnvironment: ObservableObject {
    // Existing services (from boilerplate)
    let authService: AuthService
    let apiClient: APIClient
    let analyticsService: AnalyticsService
    let logger: LoggerService
    let featureFlags: FeatureFlagService
    let sessionStore: SessionStore

    // Outfit app services
    let storeKit: StoreKitService
    let outfitStore: OutfitStore
    let clothingFetch: ClothingFetchService
    let aiStyle: AIStyleService
    let discovery: DiscoveryService

    @Published var appState: AppState

    init(authService: AuthService,
         apiClient: APIClient,
         analyticsService: AnalyticsService,
         logger: LoggerService,
         featureFlags: FeatureFlagService,
         sessionStore: SessionStore,
         storeKit: StoreKitService,
         outfitStore: OutfitStore,
         clothingFetch: ClothingFetchService,
         aiStyle: AIStyleService,
         discovery: DiscoveryService) {
        self.authService      = authService
        self.apiClient        = apiClient
        self.analyticsService = analyticsService
        self.logger           = logger
        self.featureFlags     = featureFlags
        self.sessionStore     = sessionStore
        self.storeKit         = storeKit
        self.outfitStore      = outfitStore
        self.clothingFetch    = clothingFetch
        self.aiStyle          = aiStyle
        self.discovery        = discovery
        self.appState = AppState(
            isOnboardingComplete: sessionStore.isOnboardingComplete,
            isAuthenticated: sessionStore.isAuthenticated
        )
    }

    static func bootstrap(config: AppConfig = .default) -> AppEnvironment {
        let sessionStore = SessionStore()
        let logger = AppLogger()
        return AppEnvironment(
            authService:      MockAuthService(sessionStore: sessionStore),
            apiClient:        MockAPIClient(baseURL: config.apiBaseURL),
            analyticsService: MockAnalyticsService(enabled: config.analyticsEnabled),
            logger:           logger,
            featureFlags:     DefaultFeatureFlags(config: config),
            sessionStore:     sessionStore,
            storeKit:         StoreKitService(),
            outfitStore:      OutfitStore(),
            clothingFetch:    ClothingFetchService(),
            aiStyle:          AIStyleService(),
            discovery:        DiscoveryService()
        )
    }

    func completeOnboarding() {
        sessionStore.isOnboardingComplete = true
        appState.isOnboardingComplete = true
    }

    func setAuthenticated(_ value: Bool) {
        sessionStore.isAuthenticated = value
        appState.isAuthenticated = value
    }

    // Debug override — long-press plan card in Profile to toggle
    @Published var debugPremiumOverride: Bool = false

    // Convenience: is the current user on premium?
    var isPremium: Bool { debugPremiumOverride || storeKit.tier == .premium }

    func toggleDebugPremium() {
        debugPremiumOverride.toggle()
    }
}

struct AppState {
    var isOnboardingComplete: Bool
    var isAuthenticated: Bool
}
