import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var env: AppEnvironment
    @State private var email = ""
    @State private var password = ""
    @State private var error: String?

    var body: some View {
        VStack(spacing: 16) {
            Text("Login").font(DSTypography.title)
            DSTextField(title: "Email", text: $email)
            SecureField("Password", text: $password).textFieldStyle(.roundedBorder)
            if let error { ErrorStateView(message: error) }
            Button("Sign In") { Task { await login() } }.buttonStyle(PrimaryButtonStyle())
            NavigationLink("Need an account? Register", destination: RegisterView())
        }.padding()
    }

    private func login() async {
        do {
            _ = try await env.authService.login(email: email, password: password)
            env.setAuthenticated(true)
        } catch { self.error = error.localizedDescription }
    }
}

struct RegisterView: View {
    @EnvironmentObject private var env: AppEnvironment
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Register").font(DSTypography.title)
            DSTextField(title: "Email", text: $email)
            SecureField("Password", text: $password).textFieldStyle(.roundedBorder)
            Button("Create Account") { Task { _ = try? await env.authService.register(email: email, password: password); env.setAuthenticated(true) } }
                .buttonStyle(PrimaryButtonStyle())
        }.padding()
    }
}
