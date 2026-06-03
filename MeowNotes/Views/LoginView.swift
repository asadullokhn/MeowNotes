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
    @State private var guestLoading = false
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

                Text(isRegister ? "Make a calm space for your cat." : "Sign in to continue.")
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
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(Color("XBtnBg"))
                        .underline()
                        .frame(maxWidth: .infinity)
                }
                .padding(.top, 16)

                if !isRegister {
                    Button("Forgot password?") { showForgot = true }
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(Color("XBtnBg"))
                        .underline()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 10)
                }

                guestSection
                    .padding(.top, 32)
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

    // Start without an account. Lands in onboarding (a guest has no cats yet);
    // the user can claim a full account later from the profile screen.
    private var guestSection: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                Rectangle().fill(Color("TextColor").opacity(0.12)).frame(height: 1)
                Text("or")
                    .font(.caption)
                    .foregroundColor(Color("TextColor").opacity(0.4))
                Rectangle().fill(Color("TextColor").opacity(0.12)).frame(height: 1)
            }

            Button(action: continueAsGuest) {
                ZStack {
                    if guestLoading {
                        ProgressView().tint(Color("TextColor"))
                    } else {
                        Text("Continue as guest").fontWeight(.semibold)
                    }
                }
                .foregroundColor(Color("TextColor"))
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color("BubbleBg"))
                .clipShape(RoundedRectangle(cornerRadius: 26))
                .overlay(
                    RoundedRectangle(cornerRadius: 26)
                        .stroke(Color("BubbleBorder"), lineWidth: 1)
                )
                .opacity(guestLoading ? 0.6 : 1)
            }
            .disabled(guestLoading || loading)

            Text("No account needed — claim one later to keep your cats safe.")
                .font(.caption2)
                .foregroundColor(Color("TextColor").opacity(0.5))
                .multilineTextAlignment(.center)
        }
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

    private func continueAsGuest() {
        guard !guestLoading, !loading else { return }
        error = ""
        guestLoading = true
        Task {
            do {
                try await auth.continueAsGuest()
                onSignIn()
            } catch {
                self.error = error.localizedDescription
            }
            guestLoading = false
        }
    }
}

#Preview {
    LoginView(onSignIn: {})
        .environment(AuthManager())
}
