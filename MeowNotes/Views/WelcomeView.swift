// Owner: Asad
//
// First-launch onboarding. Shown when the (guest or registered) user has no
// cats yet: collect the first cat's name + photo, then ContentView swaps to
// HomeView automatically once a cat exists.

import SwiftUI

struct WelcomeView: View {
    @Environment(AuthManager.self) private var auth

    @State private var name = ""
    @State private var pickedDataURL: String?
    @State private var saving = false
    @State private var errorMessage: String?

    private var trimmedName: String { name.trimmingCharacters(in: .whitespaces) }
    private var canSave: Bool { !trimmedName.isEmpty }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 10) {
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color(.appBg))
                            .frame(width: 44, height: 44)
                            .background(Color(.saveBg), in: RoundedRectangle(cornerRadius: 14))
                        Text("MeowNotes")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Color(.text))
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 28)

                    Text("Let's meet your cat.")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(Color(.text))
                    Text("Start with a name and a photo — you can add routine, quirks, medical and the rest from the home screen.")
                        .font(.subheadline)
                        .foregroundStyle(Color(.text).opacity(0.6))
                        .padding(.top, 6)
                        .padding(.bottom, 22)

                    CatPhotoWell(
                        existingPhotoURL: "",
                        dataURL: $pickedDataURL,
                        errorMessage: $errorMessage,
                        fillWidth: true,
                        height: 190,
                        cornerRadius: 22,
                        showActionLabel: true
                    )

                    Text("NAME")
                        .font(.caption2.weight(.semibold))
                        .tracking(0.5)
                        .foregroundStyle(Color(.text).opacity(0.5))
                        .padding(.top, 16)
                        .padding(.bottom, 6)

                    TextField("Mochi", text: $name)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(Color(.text))
                        .textInputAutocapitalization(.words)
                        .submitLabel(.done)
                        .onSubmit(create)
                        .padding(.horizontal, 16)
                        .frame(height: 56)
                        .background(Color(.bubbleBg), in: RoundedRectangle(cornerRadius: 18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color(.bubbleBorder), lineWidth: 1)
                        )

                    if let errorMessage {
                        AuthErrorBanner(message: errorMessage)
                            .padding(.top, 14)
                    }
                }
                .padding(24)
            }

            Button {
                create()
            } label: {
                Group {
                    if saving {
                        ProgressView().tint(.white)
                    } else {
                        Text("Add \(trimmedName.isEmpty ? "my cat" : trimmedName)")
                            .fontWeight(.semibold)
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color(.saveBg))
                .clipShape(RoundedRectangle(cornerRadius: 27))
                .opacity(canSave && !saving ? 1 : 0.5)
            }
            .disabled(!canSave || saving)
            .padding(.horizontal, 24)
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
                // On success, auth.cats becomes non-empty and ContentView shows HomeView.
                try await auth.addCat(name: trimmedName, photo: pickedDataURL)
            } catch {
                errorMessage = error.localizedDescription
            }
            saving = false
        }
    }
}

#Preview {
    WelcomeView()
        .environment(AuthManager())
}
