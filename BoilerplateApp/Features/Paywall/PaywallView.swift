import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var env: AppEnvironment
    @State private var subscribed = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Upgrade to Pro").font(.largeTitle.bold())
            Text(subscribed ? "You are subscribed" : "Unlock premium features")
            Button("Subscribe") {
                Task { subscribed = (try? await env.subscriptionService.purchase()) ?? false }
            }.buttonStyle(PrimaryButtonStyle())
        }
        .padding()
        .task { subscribed = await env.subscriptionService.isSubscribed() }
    }
}
