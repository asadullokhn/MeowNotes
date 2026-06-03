// Owner: Asad
//
// Edit the owner's profile (name, phone) via PATCH /api/me.
// Works for guests and registered accounts. Presented from AccountView.

import SwiftUI

struct ProfileEditView: View {
    @Environment(AuthManager.self) private var auth
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var phone = ""
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
                    AuthField(label: "Phone · optional", placeholder: "+62 812 3456 7890", text: $phone,
                              keyboard: .phonePad, textContentType: .telephoneNumber,
                              submitLabel: .done, onSubmit: submit)

                    if !error.isEmpty { AuthErrorBanner(message: error) }
                }
                .padding(24)
            }
            .background(Color("AppBg").ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color("TextColor"))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: submit) {
                        if loading { ProgressView() }
                        else { Text("Save").fontWeight(.semibold) }
                    }
                    .foregroundColor(Color("TextColor"))
                    .disabled(!canSubmit || loading)
                }
            }
            .onAppear {
                if let user = auth.user {
                    if name.isEmpty { name = user.name }
                    if phone.isEmpty { phone = user.phone ?? "" }
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
                    phone: phone.trimmingCharacters(in: .whitespaces)
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
