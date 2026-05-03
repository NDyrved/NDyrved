import Foundation

struct AppConfig {
    let apiBaseURL: URL
    let analyticsEnabled: Bool
    let paywallEnabled: Bool

    static let `default` = AppConfig(
        apiBaseURL: URL(string: "https://api.example.com")!,
        analyticsEnabled: true,
        paywallEnabled: true
    )
}
