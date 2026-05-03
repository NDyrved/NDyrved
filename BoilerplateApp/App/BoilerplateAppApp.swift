import SwiftUI

@main
struct BoilerplateAppApp: App {
    @StateObject private var environment = AppEnvironment.bootstrap()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(environment)
        }
    }
}
