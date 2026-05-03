import Foundation

@MainActor
final class AppEnvironment: ObservableObject {
    let authService: AuthService
    let apiClient: APIClient
    let subscriptionService: SubscriptionService
    let analyticsService: AnalyticsService
    let logger: LoggerService
    let featureFlags: FeatureFlagService
    let sessionStore: SessionStore

    @Published var appState: AppState

    init(authService: AuthService,
         apiClient: APIClient,
         subscriptionService: SubscriptionService,
         analyticsService: AnalyticsService,
         logger: LoggerService,
         featureFlags: FeatureFlagService,
         sessionStore: SessionStore) {
        self.authService = authService
        self.apiClient = apiClient
        self.subscriptionService = subscriptionService
        self.analyticsService = analyticsService
        self.logger = logger
        self.featureFlags = featureFlags
        self.sessionStore = sessionStore
        self.appState = AppState(isOnboardingComplete: sessionStore.isOnboardingComplete,
                                 isAuthenticated: sessionStore.isAuthenticated)
    }

    static func bootstrap(config: AppConfig = .default) -> AppEnvironment {
        let sessionStore = SessionStore()
        let logger = AppLogger()
        return AppEnvironment(
            authService: MockAuthService(sessionStore: sessionStore),
            apiClient: MockAPIClient(baseURL: config.apiBaseURL),
            subscriptionService: MockSubscriptionService(),
            analyticsService: MockAnalyticsService(enabled: config.analyticsEnabled),
            logger: logger,
            featureFlags: DefaultFeatureFlags(config: config),
            sessionStore: sessionStore
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
}

struct AppState {
    var isOnboardingComplete: Bool
    var isAuthenticated: Bool
}
