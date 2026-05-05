import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var env: AppEnvironment

    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Privacy Policy", destination: PrivacyPolicyView())
                NavigationLink("Terms of Service", destination: TermsOfServiceView())

                Section("About") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Affiliate Disclosure")
                            .font(DSTypography.bodyMedium)
                            .foregroundStyle(DSColor.textPrimary)
                        Text("Mirra earns a small commission when you purchase through links in the app, at no extra cost to you. This helps keep the app free.")
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColor.textSecondary)
                    }
                    .padding(.vertical, 4)
                }

                Button("Logout", role: .destructive) {
                    Task { await env.authService.logout(); env.setAuthenticated(false) }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
