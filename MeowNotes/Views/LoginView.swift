// Owner: Asad
//
// Auth screen: flips between Sign in and Create account. Re-implements the web
// reference (src/views/Login.vue + useAuth.js) in SwiftUI.
// Calls `onSignIn()` after a successful auth for ContentView's contract; routing
// is actually driven by AuthManager.phase via the environment.

import SwiftUI

struct LoginView: View {
    var onSignIn: () -> Void

    @Environment(AuthManager.self) private var auth

    private enum Mode { case login, register }
    @State private var mode: Mode = .login
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var loading = false
    @State private var error = ""
    @State private var showForgot = false

    private var isRegister: Bool { mode == .register }

    private var canSubmit: Bool {
        guard AuthValidation.isValidEmail(email), AuthValidation.isValidPassword(password) else { return false }
        if isRegister { return !name.trimmingCharacters(in: .whitespaces).isEmpty }
        return true
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header

                Text(isRegister ? "Make a calm space for your cat." : "Sign in to your cats.")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color("TextColor"))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 24)

                VStack(spacing: 12) {
                    if isRegister {
                        AuthField(label: "Your name", text: $name,
                                  textContentType: .name)
                    }
                    AuthField(label: "Email", placeholder: "you@example.com", text: $email,
                              keyboard: .emailAddress, textContentType: .emailAddress)
                    AuthField(label: "Password", text: $password, isSecure: true,
                              textContentType: isRegister ? .newPassword : .password,
                              submitLabel: .go, onSubmit: submit)

                    if !error.isEmpty {
                        AuthErrorBanner(message: error)
                    }

                    AuthPrimaryButton(
                        title: isRegister ? "Create account" : "Sign in",
                        loading: loading,
                        disabled: !canSubmit,
                        action: submit
                    )
                    .padding(.top, 4)
                }

                Button(action: flip) {
                    Text(isRegister ? "Have an account? Sign in" : "New here? Create an account")
                        .font(.footnote.weight(.medium))
                        .foregroundColor(Color("TextColor").opacity(0.6))
                        .frame(maxWidth: .infinity)
                }
                .padding(.top, 14)

                if !isRegister {
                    Button("Forgot password?") { showForgot = true }
                        .font(.footnote.weight(.medium))
                        .foregroundColor(Color("XBtnBg"))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                }

                demoAccounts
                    .padding(.top, 36)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
        .background(Color("AppBg").ignoresSafeArea())
        .sheet(isPresented: $showForgot) {
            ForgotPasswordView(prefillEmail: email)
        }
    }

    // MARK: - Sections

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: "pawprint.fill")
                .font(.system(size: 22))
                .foregroundColor(Color("AppBg"))
                .frame(width: 44, height: 44)
                .background(Color("SaveBg"))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            Text("MeowNotes")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color("TextColor"))
        }
        .padding(.bottom, 28)
    }

    private var demoAccounts: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text("DEMO")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.2)
                    .foregroundColor(Color("SaveBg"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color("XBtnBg").opacity(0.25))
                    .clipShape(Capsule())
                Text("Quick-fill a seeded account")
                    .font(.caption)
                    .foregroundColor(Color("TextColor").opacity(0.6))
            }

            HStack(spacing: 10) {
                demoCard(name: "Edward", subtitle: "Owns Mochi", symbol: "person.fill") {
                    fillDemo(email: "edward@meownotes.app", password: "mochi123")
                }
                demoCard(name: "Anya", subtitle: "Owns Luna", symbol: "person.fill") {
                    fillDemo(email: "anya@meownotes.app", password: "luna123")
                }
            }
        }
    }

    private func demoCard(name: String, subtitle: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: symbol)
                    .foregroundColor(Color("SaveBg"))
                    .frame(width: 36, height: 36)
                    .background(Color("AppBg"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Color("TextColor"))
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(Color("TextColor").opacity(0.6))
                }
                Spacer(minLength: 0)
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color("BubbleBorder"), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func submit() {
        guard canSubmit, !loading else { return }
        error = ""
        loading = true
        Task {
            do {
                if isRegister {
                    try await auth.register(name: name, email: email, password: password)
                } else {
                    try await auth.login(email: email, password: password)
                }
                onSignIn()
            } catch {
                self.error = error.localizedDescription
            }
            loading = false
        }
    }

    private func flip() {
        mode = isRegister ? .login : .register
        error = ""
    }

    private func fillDemo(email: String, password: String) {
        self.email = email
        self.password = password
        mode = .login
        error = ""
    }
}

#Preview {
    LoginView(onSignIn: {})
        .environment(AuthManager())
}
