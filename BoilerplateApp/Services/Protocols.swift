import Foundation

struct UserProfile: Equatable {
    let id: UUID
    let email: String
    let displayName: String
}

protocol AuthService {
    func login(email: String, password: String) async throws -> UserProfile
    func register(email: String, password: String) async throws -> UserProfile
    func logout() async
    func currentUser() async -> UserProfile?
}

protocol APIClient {
    func fetchWelcome() async throws -> APIWelcome
}

protocol SubscriptionService {
    func isSubscribed() async -> Bool
    func purchase() async throws -> Bool
}

protocol AnalyticsService {
    func track(event: String, properties: [String: String])
}
