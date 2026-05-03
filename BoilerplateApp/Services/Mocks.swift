import Foundation

final class MockAuthService: AuthService {
    private let sessionStore: SessionStore
    private var storedUser = UserProfile(id: UUID(), email: "demo@boilerplate.app", displayName: "Demo User")

    init(sessionStore: SessionStore) { self.sessionStore = sessionStore }

    func login(email: String, password: String) async throws -> UserProfile {
        try await Task.sleep(for: .milliseconds(300))
        guard !email.isEmpty, !password.isEmpty else { throw AppError.invalidCredentials }
        storedUser = UserProfile(id: UUID(), email: email, displayName: email.components(separatedBy: "@").first ?? "User")
        sessionStore.isAuthenticated = true
        return storedUser
    }

    func register(email: String, password: String) async throws -> UserProfile {
        try await login(email: email, password: password)
    }

    func logout() async { sessionStore.isAuthenticated = false }
    func currentUser() async -> UserProfile? { sessionStore.isAuthenticated ? storedUser : nil }
}

struct MockAPIClient: APIClient {
    let baseURL: URL
    func fetchWelcome() async throws -> APIWelcome {
        try await Task.sleep(for: .milliseconds(200))
        _ = baseURL
        return APIWelcome(message: "Welcome to your reusable boilerplate.")
    }
}

actor MockSubscriptionService: SubscriptionService {
    private var subscribed = false
    func isSubscribed() async -> Bool { subscribed }
    func purchase() async throws -> Bool { subscribed = true; return true }
}

struct MockAnalyticsService: AnalyticsService {
    let enabled: Bool
    func track(event: String, properties: [String : String]) {
        guard enabled else { return }
        print("Analytics event: \(event), \(properties)")
    }
}
