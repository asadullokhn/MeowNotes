// Owner: TBD (claim by editing this line)
//
// Modal sheet to add a new cat to the user's account. Ported from MochiApp's
// NewCatSheet.vue — name to start, photo optional (picked from the library and
// sent as a base64 data URL).

import SwiftUI

struct NewCatView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var auth

    @State private var name = ""
    @State private var pickedDataURL: String?
    @State private var saving = false
    @State private var errorMessage: String?

    private var trimmedName: String { name.trimmingCharacters(in: .whitespaces) }
    private var canSave: Bool { !trimmedName.isEmpty }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("What's their \(Text("name").italic().font(.system(size: 30, weight: .bold, design: .serif)))?")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(Color(.text))

                        Text("Just the name to start — a photo is optional. You can add routine, quirks and the rest after.")
                            .font(.subheadline)
                            .foregroundStyle(Color(.text).opacity(0.6))
                            .padding(.top, 6)
                            .padding(.bottom, 20)

                        HStack(spacing: 12) {
                            CatPhotoWell(
                                existingPhotoURL: "",
                                dataURL: $pickedDataURL,
                                errorMessage: $errorMessage,
                                height: 80
                            )

                            TextField("Mochi", text: $name)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(Color(.text))
                                .textInputAutocapitalization(.words)
                                .submitLabel(.done)
                                .onSubmit(create)
                                .padding(.horizontal, 16)
                                .frame(height: 80)
                                .background(Color(.bubbleBg), in: RoundedRectangle(cornerRadius: 18))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color(.bubbleBorder), lineWidth: 1)
                                )
                        }

                        if let errorMessage {
                            AuthErrorBanner(message: errorMessage)
                                .padding(.top, 14)
                        }
                    }
                    .padding()
                }

                footer
            }
            .background(Color(.background))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("NEW CAT")
                        .fixedSize()
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(.text))
                }
                .sharedBackgroundVisibility(.hidden)

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 12, height: 12)
                    }
                }
            }
        }
    }

    private var footer: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color(.bubbleBorder))
                .frame(height: 1)

            HStack(spacing: 10) {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(.text))
                        .frame(maxWidth: 110)
                        .frame(height: 52)
                        .background(Color(.bubbleBg))
                        .clipShape(RoundedRectangle(cornerRadius: 26))
                        .overlay(
                            RoundedRectangle(cornerRadius: 26)
                                .stroke(Color(.bubbleBorder), lineWidth: 1)
                        )
                }

                Button {
                    create()
                } label: {
                    Group {
                        if saving {
                            ProgressView().tint(.white)
                        } else {
                            Text("Add \(trimmedName.isEmpty ? "cat" : trimmedName)")
                                .fontWeight(.semibold)
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(.saveBg))
                    .clipShape(RoundedRectangle(cornerRadius: 26))
                    .opacity(canSave && !saving ? 1 : 0.5)
                }
                .disabled(!canSave || saving)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(.background))
    }

    private func create() {
        guard canSave, !saving else { return }
        saving = true
        errorMessage = nil
        Task {
            do {
                try await auth.addCat(name: trimmedName, photo: pickedDataURL)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
            saving = false
        }
    }
}

#Preview {
    NewCatView()
        .environment(AuthManager())
}
