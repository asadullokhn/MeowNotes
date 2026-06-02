// Owner: Asad
//
// Edit the owner's profile (name, phone, location) via PATCH /api/me.
// Works for guests and registered accounts. Presented from AccountView.

import SwiftUI

struct ProfileEditView: View {
    @Environment(AuthManager.self) private var auth
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var phone = ""
    @State private var location = ""
    @State private var loading = false
    @State private var error = ""

    private var canSubmit: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Edit profile.")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(Color("TextColor"))

                    AuthField(label: "Your name", text: $name, textContentType: .name)
                    AuthField(label: "Phone · optional", placeholder: "+998 90 123 45 67", text: $phone,
                              keyboard: .phonePad, textContentType: .telephoneNumber)
                    AuthField(label: "Location · optional", placeholder: "Tashkent", text: $location,
                              textContentType: .addressCity, submitLabel: .done, onSubmit: submit)

                    if !error.isEmpty { AuthErrorBanner(message: error) }

                    AuthPrimaryButton(title: "Save", loading: loading,
                                      disabled: !canSubmit, action: submit)
                        .padding(.top, 4)
                }
                .padding(24)
            }
            .background(Color("AppBg").ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                        .foregroundColor(Color("TextColor"))
                }
            }
            .onAppear {
                if let user = auth.user {
                    if name.isEmpty { name = user.name }
                    if phone.isEmpty { phone = user.phone ?? "" }
                    if location.isEmpty { location = user.location ?? "" }
                }
            }
        }
    }

    private func submit() {
        guard canSubmit, !loading else { return }
        error = ""
        loading = true
        Task {
            do {
                try await auth.updateProfile(
                    name: name.trimmingCharacters(in: .whitespaces),
                    phone: phone.trimmingCharacters(in: .whitespaces),
                    location: location.trimmingCharacters(in: .whitespaces)
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
    ProfileEditView()
        .environment(AuthManager())
}
