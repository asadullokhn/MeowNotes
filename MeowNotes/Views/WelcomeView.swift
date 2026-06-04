// Owner: Asad
//
// First-launch onboarding. Shown when the (guest or registered) user has no
// cats yet: collect the first cat's name + photo, then ContentView swaps to
// HomeView automatically once a cat exists.

import SwiftUI

struct WelcomeView: View {
    // `true` when adding another cat later (shown as a sheet from Home) vs. the
    // first-launch onboarding. Adds a close button and dismisses on success.
    var isAdditional: Bool = false
    @Environment(AuthManager.self) private var auth
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var dob: Date?            // nil = unset (optional)
    @State private var sex = ""              // "" = unset (optional)
    @State private var pickedDataURL: String?
    @State private var saving = false
    @State private var errorMessage: String?

    private var trimmedName: String { name.trimmingCharacters(in: .whitespaces) }
    private var canSave: Bool { !trimmedName.isEmpty }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Top bar: navigation only (no app branding) — back to sign-in
                    // on first launch, or a close button when adding another cat.
                    HStack {
                        if isAdditional {
                            Spacer()
                            Button { dismiss() } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(Color(.text).opacity(0.6))
                                    .frame(width: 36, height: 36)
                                    .background(Color(.bubbleBg), in: Circle())
                            }
                            .accessibilityLabel("Close")
                        } else {
                            Button { auth.logout() } label: {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(Color(.text).opacity(0.6))
                                    .frame(width: 36, height: 36)
                                    .background(Color(.bubbleBg), in: Circle())
                            }
                            .accessibilityLabel("Back to sign in")
                            Spacer()
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 24)

                    Text(isAdditional ? "Add another cat." : "Let's meet your cat.")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(.text))
                        .accessibilityAddTraits(.isHeader)
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

                    SectionLabel("Name", dimmed: true)
                        .padding(.top, 16)
                        .padding(.bottom, 6)

                    TextField("Mochi", text: $name)
                        .font(.title3.weight(.medium))
                        .foregroundStyle(Color(.text))
                        .textInputAutocapitalization(.words)
                        .submitLabel(.done)
                        .onSubmit(create)
                        .characterLimit(50, $name)
                        .padding(.horizontal, 16)
                        .frame(height: 56)
                        .background(Color(.bubbleBg), in: RoundedRectangle(cornerRadius: 18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color(.bubbleBorder), lineWidth: 1)
                        )

                    // Optional details — a cat is fine with just a name; these can
                    // also be set later from Edit profile.
                    SectionLabel("Date of birth · optional", dimmed: true)
                        .padding(.top, 16)
                        .padding(.bottom, 6)

                    CatDOBField(dob: $dob)

                    SectionLabel("Sex · optional", dimmed: true)
                        .padding(.top, 16)
                        .padding(.bottom, 6)

                    HStack(spacing: 10) {
                        ForEach(["Male", "Female"], id: \.self) { option in
                            Button { sex = (sex == option ? "" : option) } label: {
                                Text(option)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(sex == option ? .white : Color(.text).opacity(0.75))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(sex == option ? Color(.saveBg) : Color(.bubbleBg), in: Capsule())
                                    .overlay(Capsule().stroke(Color(.bubbleBorder), lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }

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
        let dobString = dob.map(AgeFormat.iso)
        Task {
            do {
                try await auth.addCat(
                    name: trimmedName,
                    photo: pickedDataURL,
                    dob: dobString,
                    gender: sex.isEmpty ? nil : sex
                )
                // First launch: cats becomes non-empty and ContentView shows Home
                // (dismiss is a no-op). Adding another: closes the sheet.
                dismiss()
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
