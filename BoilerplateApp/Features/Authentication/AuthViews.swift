import SwiftUI
import AuthenticationServices

struct AuthView: View {
    @State private var showRegister = false
    var body: some View {
        if showRegister { RegisterView(showRegister: $showRegister) }
        else            { LoginView(showRegister: $showRegister) }
    }
}

// MARK: - Login
struct LoginView: View {
    @EnvironmentObject private var env: AppEnvironment
    @Binding var showRegister: Bool

    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header block
                VStack(spacing: 16) {
                    Text("Welcome\nBack")
                        .font(DSTypography.display)
                        .foregroundStyle(DSColor.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Sign in to your wardrobe")
                        .font(DSTypography.body)
                        .foregroundStyle(DSColor.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 24)
                .padding(.top, 56)
                .padding(.bottom, 40)

                VStack(spacing: 16) {
                    // Sign in with Apple
                    SignInWithAppleButton(.signIn) { req in
                        req.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        handleApple(result)
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 56)
                    .cornerRadius(16)

                    divider

                    DSTextField(title: "Email address", text: $email, icon: "envelope")
                        .keyboardType(.emailAddress)
                    DSTextField(title: "Password", text: $password, icon: "lock", isSecure: true)

                    if let error = errorMessage {
                        Text(error)
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColor.destructive)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        Task { await login() }
                    } label: {
                        Group {
                            if isLoading { ProgressView().tint(.white) }
                            else { Text("Sign In") }
                        }.frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(isLoading)

                    Button("Don't have an account? Create one") { showRegister = true }
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColor.accent)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .background(DSColor.background.ignoresSafeArea())
    }

    private var divider: some View {
        HStack {
            Rectangle().fill(DSColor.border).frame(height: 1)
            Text("or").font(DSTypography.caption).foregroundStyle(DSColor.textTertiary).padding(.horizontal, 12)
            Rectangle().fill(DSColor.border).frame(height: 1)
        }
    }

    private func login() async {
        isLoading = true; errorMessage = nil
        do {
            _ = try await env.authService.login(email: email, password: password)
            env.setAuthenticated(true)
        } catch { errorMessage = error.localizedDescription }
        isLoading = false
    }

    private func handleApple(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success: env.setAuthenticated(true)
        case .failure(let e): errorMessage = e.localizedDescription
        }
    }
}

// MARK: - Register
struct RegisterView: View {
    @EnvironmentObject private var env: AppEnvironment
    @Binding var showRegister: Bool

    @State private var email = ""
    @State private var password = ""
    @State private var confirm = ""
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    Text("Create\nAccount")
                        .font(DSTypography.display)
                        .foregroundStyle(DSColor.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 24)
                .padding(.top, 56)
                .padding(.bottom, 40)

                VStack(spacing: 16) {
                    SignInWithAppleButton(.signUp) { req in
                        req.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        switch result {
                        case .success: env.setAuthenticated(true)
                        case .failure(let e): errorMessage = e.localizedDescription
                        }
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 56)
                    .cornerRadius(16)

                    DSTextField(title: "Email address", text: $email, icon: "envelope")
                        .keyboardType(.emailAddress)
                    DSTextField(title: "Password", text: $password, icon: "lock", isSecure: true)
                    DSTextField(title: "Confirm password", text: $confirm, icon: "lock", isSecure: true)

                    if let error = errorMessage {
                        Text(error).font(DSTypography.caption).foregroundStyle(DSColor.destructive)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        Task { await register() }
                    } label: {
                        Group {
                            if isLoading { ProgressView().tint(.white) }
                            else { Text("Create Account") }
                        }.frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(isLoading)

                    Button("Already have an account? Sign In") { showRegister = false }
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColor.accent)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .background(DSColor.background.ignoresSafeArea())
    }

    private func register() async {
        guard password == confirm else { errorMessage = "Passwords don't match."; return }
        isLoading = true; errorMessage = nil
        do {
            _ = try await env.authService.register(email: email, password: password)
            env.setAuthenticated(true)
        } catch { errorMessage = error.localizedDescription }
        isLoading = false
    }
}
