// Owner: Asad
//
// "Save your account" — converts the current anonymous guest into a full
// account (POST /api/auth/claim), keeping all of their cats. Presented from
// AccountView when the signed-in user is a guest.

import SwiftUI

struct ClaimAccountView: View {
    @Environment(AuthManager.self) private var auth
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var loading = false
    @State private var error = ""

    private var canSubmit: Bool {
        AuthValidation.isValidEmail(email)
            && AuthValidation.isValidPassword(password)
            && !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Create your account.")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(Color("TextColor"))
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Keep your cats and sign in on another device. Your data stays exactly as it is.")
                        .font(.subheadline)
                        .foregroundColor(Color("TextColor").opacity(0.6))

                    AuthField(label: "Your name", text: $name, textContentType: .name)
                    AuthField(label: "Email", placeholder: "you@example.com", text: $email,
                              keyboard: .emailAddress, textContentType: .emailAddress)
                    AuthField(label: "Password", text: $password, isSecure: true,
                              textContentType: .newPassword, submitLabel: .go, onSubmit: submit)

                    Text("Password must be at least 6 characters.")
                        .font(.caption)
                        .foregroundColor(Color("TextColor").opacity(0.5))

                    if !error.isEmpty { AuthErrorBanner(message: error) }

                    AuthPrimaryButton(title: "Save", loading: loading,
                                      disabled: !canSubmit, action: submit)
                        .padding(.top, 4)
                }
                .padding(24)
            }
            .background(Color("AppBg").ignoresSafeArea())
            .navigationTitle("Create account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                        .foregroundColor(Color("TextColor"))
                }
            }
            .onAppear {
                // Pre-fill the real name if the guest already set one (skip the "Guest" default).
                if name.isEmpty, let n = auth.user?.name, n != "Guest" { name = n }
            }
        }
    }

    private func submit() {
        guard canSubmit, !loading else { return }
        error = ""
        loading = true
        Task {
            do {
                try await auth.claim(
                    email: email.trimmingCharacters(in: .whitespaces),
                    name: name.trimmingCharacters(in: .whitespaces),
                    password: password
                )
                dismiss()
            } catch {
                self.error = error.localizedDescription
            }
            loading = false
        }
    }
}

#Preview {
    ClaimAccountView()
        .environment(AuthManager())
}
