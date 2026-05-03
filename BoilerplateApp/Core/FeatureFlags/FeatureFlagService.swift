import Foundation

protocol FeatureFlagService {
    func isEnabled(_ flag: FeatureFlag) -> Bool
}

enum FeatureFlag {
    case paywall
}

struct DefaultFeatureFlags: FeatureFlagService {
    private let config: AppConfig
    init(config: AppConfig) { self.config = config }
    func isEnabled(_ flag: FeatureFlag) -> Bool {
        switch flag {
        case .paywall: return config.paywallEnabled
        }
    }
}
