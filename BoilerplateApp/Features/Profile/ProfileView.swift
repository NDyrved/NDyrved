import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var env: AppEnvironment
    @State private var profile: UserProfile?

    var body: some View {
        VStack(spacing: 12) {
            Text("Profile").font(.title.bold())
            Text(profile?.displayName ?? "Unknown")
            Text(profile?.email ?? "-")
        }
        .task { profile = await env.authService.currentUser() }
        .padding()
    }
}
