// Owner: Asad
//
// Change Password — old + new password while signed in.
// Not in the web reference: new flow, no backend yet, so
// AuthManager.changePassword is a stub.

import SwiftUI

struct ChangePasswordView: View {
    @Environment(AuthManager.self) private var auth
    @Environment(\.dismiss) private var dismiss

    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var loading = false
    @State private var error = ""
    @State private var succeeded = false

    private var canSubmit: Bool {
        !currentPassword.isEmpty
            && AuthValidation.isValidPassword(newPassword)
            && newPassword == confirmPassword
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if succeeded {
                        successState
                    } else {
                        formState
                    }
                }
                .padding(24)
            }
            .background(Color("AppBg").ignoresSafeArea())
            .navigationTitle("Change password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                        .foregroundColor(Color("TextColor"))
                }
            }
        }
    }

    private var formState: some View {
        VStack(spacing: 12) {
            AuthField(label: "Current password", text: $currentPassword, isSecure: true,
                      textContentType: .password)
            AuthField(label: "New password", text: $newPassword, isSecure: true,
                      textContentType: .newPassword)
            AuthField(label: "Confirm new password", text: $confirmPassword, isSecure: true,
                      textContentType: .newPassword, submitLabel: .go, onSubmit: submit)

            if !confirmPassword.isEmpty && newPassword != confirmPassword {
                Text("Passwords don't match.")
                    .font(.caption)
                    .foregroundColor(Color(red: 0.79, green: 0.44, blue: 0.42))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if !error.isEmpty { AuthErrorBanner(message: error) }

            AuthPrimaryButton(title: "Update password", loading: loading,
                              disabled: !canSubmit, action: submit)

            Text("Password must be at least 6 characters.")
                .font(.caption)
                .foregroundColor(Color("TextColor").opacity(0.5))
        }
    }

    private var successState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(Color("XBtnBg"))
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
            Text("Password updated.")
                .font(.headline)
                .foregroundColor(Color("TextColor"))
                .frame(maxWidth: .infinity)
            AuthPrimaryButton(title: "Done") { dismiss() }
        }
    }

    private func submit() {
        guard canSubmit, !loading else { return }
        error = ""
        loading = true
        Task {
            do {
                try await auth.changePassword(currentPassword: currentPassword, newPassword: newPassword)
                succeeded = true
            } catch {
                self.error = error.localizedDescription
            }
            loading = false
        }
    }
}

#Preview {
    ChangePasswordView()
        .environment(AuthManager())
}
