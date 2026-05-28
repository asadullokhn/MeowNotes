// Owner: Asad
//
// Forgot Password — request a reset code by email, then set a new password.
// Not in the web reference: this flow is new and has no backend yet, so
// AuthManager.requestPasswordReset / resetPassword are stubs.

import SwiftUI

struct ForgotPasswordView: View {
    var prefillEmail: String = ""

    @Environment(AuthManager.self) private var auth
    @Environment(\.dismiss) private var dismiss

    private enum Step { case request, reset, done }
    @State private var step: Step = .request
    @State private var email = ""
    @State private var code = ""
    @State private var newPassword = ""
    @State private var loading = false
    @State private var error = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(headline)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(Color("TextColor"))
                        .fixedSize(horizontal: false, vertical: true)

                    switch step {
                    case .request: requestStep
                    case .reset:   resetStep
                    case .done:    doneStep
                    }
                }
                .padding(24)
            }
            .background(Color("AppBg").ignoresSafeArea())
            .navigationTitle("Reset password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                        .foregroundColor(Color("TextColor"))
                }
            }
        }
        .onAppear { if email.isEmpty { email = prefillEmail } }
    }

    private var headline: String {
        switch step {
        case .request: return "We'll send a reset code to your email."
        case .reset:   return "Enter the code and a new password."
        case .done:    return "Your password has been reset."
        }
    }

    private var requestStep: some View {
        VStack(spacing: 12) {
            AuthField(label: "Email", placeholder: "you@example.com", text: $email,
                      keyboard: .emailAddress, textContentType: .emailAddress,
                      submitLabel: .send, onSubmit: requestReset)

            if !error.isEmpty { AuthErrorBanner(message: error) }

            AuthPrimaryButton(title: "Send reset code", loading: loading,
                              disabled: !AuthValidation.isValidEmail(email),
                              action: requestReset)
        }
    }

    private var resetStep: some View {
        VStack(spacing: 12) {
            AuthField(label: "Reset code", placeholder: "6-digit code", text: $code,
                      keyboard: .numberPad)
            AuthField(label: "New password", text: $newPassword, isSecure: true,
                      textContentType: .newPassword, submitLabel: .go, onSubmit: resetPassword)

            if !error.isEmpty { AuthErrorBanner(message: error) }

            AuthPrimaryButton(
                title: "Set new password", loading: loading,
                disabled: code.trimmingCharacters(in: .whitespaces).isEmpty
                    || !AuthValidation.isValidPassword(newPassword),
                action: resetPassword
            )

            Text("Password must be at least 6 characters.")
                .font(.caption)
                .foregroundColor(Color("TextColor").opacity(0.5))
        }
    }

    private var doneStep: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(Color("XBtnBg"))
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
            AuthPrimaryButton(title: "Back to sign in") { dismiss() }
        }
    }

    private func requestReset() {
        guard AuthValidation.isValidEmail(email), !loading else { return }
        error = ""
        loading = true
        Task {
            do {
                try await auth.requestPasswordReset(email: email)
                step = .reset
            } catch {
                self.error = error.localizedDescription
            }
            loading = false
        }
    }

    private func resetPassword() {
        guard AuthValidation.isValidPassword(newPassword),
              !code.trimmingCharacters(in: .whitespaces).isEmpty, !loading else { return }
        error = ""
        loading = true
        Task {
            do {
                try await auth.resetPassword(email: email, code: code, newPassword: newPassword)
                step = .done
            } catch {
                self.error = error.localizedDescription
            }
            loading = false
        }
    }
}

#Preview {
    ForgotPasswordView(prefillEmail: "edward@meownotes.app")
        .environment(AuthManager())
}
