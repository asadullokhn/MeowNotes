//
//  EditCatProfileView.swift
//  MeowNotes
//
//  Modal editor for a cat's basics (name, photo, breed, age). Ported from
//  MochiApp's EditBasicsSheet.vue. Save persists via PATCH /api/cats and only
//  sends the fields that are set, so a blank field doesn't overwrite existing data.
//
import SwiftUI

struct EditCatProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var auth

    @State private var name = ""
    @State private var breed = ""
    @State private var age = ""
    @State private var existingPhoto = ""
    @State private var pickedDataURL: String?
    @State private var saving = false
    @State private var errorMessage: String?
    @State private var showingDeleteConfirm = false
    @State private var deceasedDate = Date()

    private let commonBreeds = [
        "Domestic Shorthair", "British Shorthair", "Maine Coon",
        "Persian", "Siamese", "Bengal", "Ragdoll", "Scottish Fold", "Mixed"
    ]

    // Calm periwinkle for the memorial (clearly not a destructive action) and
    // the app's terracotta for the destructive removal. Both are mid-tone so
    // they stay legible in light and dark.
    private let memorialColor = Color(red: 0.56, green: 0.56, blue: 0.80)
    private let removeColor = Color(red: 0.79, green: 0.44, blue: 0.42)

    private var catName: String { auth.currentCat?.name ?? "your cat" }
    private var trimmedName: String { name.trimmingCharacters(in: .whitespaces) }
    private var canSave: Bool { !trimmedName.isEmpty }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("A little more about them.")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Color(.text))

                        field("Name") {
                            textField("Mochi", $name)
                                .textInputAutocapitalization(.words)
                        }

                        field("Photo") {
                            CatPhotoWell(
                                existingPhotoURL: existingPhoto,
                                dataURL: $pickedDataURL,
                                errorMessage: $errorMessage,
                                fillWidth: true,
                                height: 190,
                                cornerRadius: 22,
                                showActionLabel: true
                            )
                        }

                        HStack(alignment: .top, spacing: 12) {
                            field("Breed") { textField("Mixed", $breed) }
                            field("Age") { textField("e.g. 2 years, 8 months", $age) }
                        }

                        FlowLayout(spacing: 8) {
                            ForEach(commonBreeds, id: \.self) { option in
                                Button { breed = option } label: { breedChip(option) }
                                    .buttonStyle(.plain)
                            }
                        }

                        if let errorMessage {
                            AuthErrorBanner(message: errorMessage)
                        }

                        lifecycleSection
                    }
                    .padding()
                }

                footer
            }
            .background(Color(.background))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text(catName.uppercased() + " · BASICS")
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
            .onAppear(perform: load)
            .alert("Remove \(catName)'s profile?", isPresented: $showingDeleteConfirm) {
                Button("Remove", role: .destructive) { deleteCat() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This permanently removes \(catName)'s profile and care guide. This can't be undone. To keep their profile as a memorial instead, use \u{201C}Mark as deceased.\u{201D}")
            }
        }
    }

    // MARK: - Delete / memorial

    private var lifecycleSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Rectangle()
                .fill(Color(.bubbleBorder))
                .frame(height: 1)
                .padding(.vertical, 4)

            memorialSection

            removeSection
        }
    }

    // The gentle, memorial half — a warm card when the cat has passed, or a
    // kind prompt to mark the date otherwise.
    @ViewBuilder
    private var memorialSection: some View {
        if auth.currentCat?.deceased == true {
            VStack(spacing: 10) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(memorialColor)
                Text("In loving memory of \(catName)")
                    .font(.headline)
                    .foregroundStyle(Color(.text))
                    .multilineTextAlignment(.center)
                if let date = auth.currentCat?.deceasedDate, !date.isEmpty {
                    Text(prettyDate(date))
                        .font(.subheadline)
                        .foregroundStyle(Color(.text).opacity(0.6))
                }
                Text("Their care guide stays here so you can look back any time.")
                    .font(.caption)
                    .foregroundStyle(Color(.text).opacity(0.5))
                    .multilineTextAlignment(.center)
                Button { applyDeceased(false) } label: {
                    Text("They're still with us — undo")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(memorialColor)
                }
                .padding(.top, 2)
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(Color(.bubbleBg), in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(memorialColor.opacity(0.45), lineWidth: 1.5)
            )
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text("IN MEMORY")
                    .font(.caption2.weight(.semibold))
                    .tracking(0.5)
                    .foregroundStyle(Color(.text).opacity(0.5))
                Text("If \(catName) has passed, mark the date to keep their profile as a memorial. You can undo any time.")
                    .font(.caption)
                    .foregroundStyle(Color(.text).opacity(0.6))
                HStack(spacing: 10) {
                    DatePicker("", selection: $deceasedDate, in: ...Date(), displayedComponents: .date)
                        .labelsHidden()
                    Spacer()
                    Button { applyDeceased(true) } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "heart")
                            Text("Mark as deceased")
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(memorialColor)
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.bubbleBg), in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.bubbleBorder), lineWidth: 1)
            )
        }
    }

    // The destructive half — kept visually distinct and lower down.
    private var removeSection: some View {
        Button(role: .destructive) { showingDeleteConfirm = true } label: {
            HStack(spacing: 6) {
                Image(systemName: "trash")
                Text("Remove cat profile")
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(removeColor)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(removeColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(removeColor.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func prettyDate(_ raw: String) -> String {
        let parser = DateFormatter()
        parser.dateFormat = "yyyy-MM-dd"
        guard let date = parser.date(from: raw) else { return raw }
        let out = DateFormatter()
        out.dateStyle = .long
        return out.string(from: date)
    }

    private func applyDeceased(_ deceased: Bool) {
        guard let catID = auth.currentCat?.id else { return }
        errorMessage = nil
        let dateString: String?
        if deceased {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            dateString = formatter.string(from: deceasedDate)
        } else {
            dateString = nil
        }
        Task {
            do {
                try await auth.setDeceased(catID: catID, deceased: deceased, date: dateString)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func deleteCat() {
        guard let catID = auth.currentCat?.id else { return }
        errorMessage = nil
        Task {
            do {
                try await auth.deleteCat(catID: catID)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Footer

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
                    save()
                } label: {
                    Group {
                        if saving {
                            ProgressView().tint(.white)
                        } else {
                            Text("Save").fontWeight(.semibold)
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

    // MARK: - Field helpers

    private func field<Content: View>(_ title: String, @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.caption2.weight(.semibold))
                .tracking(0.5)
                .foregroundStyle(Color(.text).opacity(0.5))
            content()
        }
    }

    private func textField(_ placeholder: String, _ text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .font(.system(size: 16))
            .foregroundStyle(Color(.text))
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(.bubbleBg), in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.bubbleBorder), lineWidth: 1)
            )
    }

    private func breedChip(_ option: String) -> some View {
        let selected = breed == option
        return Text(option)
            .font(.caption.weight(.medium))
            .foregroundStyle(selected ? .white : Color(.text).opacity(0.75))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(selected ? Color(.saveBg) : Color(.bubbleBg), in: Capsule())
            .overlay(Capsule().stroke(Color(.bubbleBorder), lineWidth: 1))
    }

    // MARK: - Load / Save

    private func load() {
        guard let cat = auth.currentCat else { return }
        name = cat.name
        breed = cat.breed ?? ""
        age = cat.age?.display ?? ""
        existingPhoto = cat.photo ?? ""
    }

    private func save() {
        guard let catID = auth.currentCat?.id, canSave, !saving else { return }
        saving = true
        errorMessage = nil
        let trimmedBreed = breed.trimmingCharacters(in: .whitespaces)
        let trimmedAge = age.trimmingCharacters(in: .whitespaces)
        Task {
            do {
                try await auth.updateBasics(
                    catID: catID,
                    name: trimmedName,
                    photo: pickedDataURL,                          // nil unless a new image was picked
                    breed: trimmedBreed.isEmpty ? nil : trimmedBreed,
                    age: trimmedAge.isEmpty ? nil : trimmedAge
                )
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
            saving = false
        }
    }
}

#Preview {
    EditCatProfileView()
        .environment(AuthManager())
}
