import Foundation

final class SessionStore {
    private enum Keys {
        static let isAuthenticated = "session.isAuthenticated"
        static let isOnboardingComplete = "session.isOnboardingComplete"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var isAuthenticated: Bool {
        get { defaults.bool(forKey: Keys.isAuthenticated) }
        set { defaults.set(newValue, forKey: Keys.isAuthenticated) }
    }

    var isOnboardingComplete: Bool {
        get { defaults.bool(forKey: Keys.isOnboardingComplete) }
        set { defaults.set(newValue, forKey: Keys.isOnboardingComplete) }
    }
}
