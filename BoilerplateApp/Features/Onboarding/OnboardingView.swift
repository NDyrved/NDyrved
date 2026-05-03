import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var env: AppEnvironment

    var body: some View {
        VStack(spacing: 20) {
            Text("BoilerplateApp").font(DSTypography.title)
            Text("Reusable SwiftUI starter with clean architecture.")
                .font(DSTypography.body)
                .multilineTextAlignment(.center)
            Button("Get Started") { env.completeOnboarding() }
                .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
    }
}
