import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var env: AppEnvironment

    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Privacy Policy", destination: PrivacyPolicyView())
                NavigationLink("Terms of Service", destination: TermsOfServiceView())
                Button("Logout", role: .destructive) {
                    Task { await env.authService.logout(); env.setAuthenticated(false) }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
