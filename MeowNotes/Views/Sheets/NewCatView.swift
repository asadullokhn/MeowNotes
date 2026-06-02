// Owner: TBD (claim by editing this line)
//
// Modal sheet to add a new cat to the user's account. Ported from MochiApp's
// NewCatSheet.vue — name to start, photo optional. The photo is picked from the
// library and sent as a base64 data URL (same shape the web uploads).

import SwiftUI
import PhotosUI
import UIKit

struct NewCatView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var auth

    @State private var name = ""
    @State private var photoItem: PhotosPickerItem?
    @State private var photoImage: Image?
    @State private var photoDataURL: String?
    @State private var saving = false
    @State private var errorMessage: String?

    private var trimmedName: String { name.trimmingCharacters(in: .whitespaces) }
    private var canSave: Bool { !trimmedName.isEmpty }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        (
                            Text("What's their ")
                            + Text("name").italic().font(.system(size: 30, weight: .bold, design: .serif))
                            + Text("?")
                        )
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(Color(.text))

                        Text("Just the name to start — a photo is optional. You can add routine, quirks and the rest after.")
                            .font(.subheadline)
                            .foregroundStyle(Color(.text).opacity(0.6))
                            .padding(.top, 6)
                            .padding(.bottom, 20)

                        HStack(spacing: 12) {
                            PhotosPicker(selection: $photoItem, matching: .images) {
                                photoThumbnail
                            }
                            .buttonStyle(.plain)

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
            .onChange(of: photoItem) { _, newItem in
                guard let newItem else { return }
                Task { await loadPhoto(newItem) }
            }
        }
    }

    private var photoThumbnail: some View {
        ZStack {
            if let photoImage {
                photoImage.resizable().scaledToFill()
            } else {
                Color(.bubbleSectionBg)
                VStack(spacing: 4) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 18))
                    Text("PHOTO")
                        .font(.system(size: 9, weight: .semibold))
                        .tracking(0.5)
                }
                .foregroundStyle(Color(.text).opacity(0.45))
            }
        }
        .frame(width: 80, height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(.bubbleBorder), lineWidth: 1)
        )
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

    // Load the picked image, downscale + JPEG-compress it, and keep it as a
    // base64 data URL to send as the cat's photo.
    private func loadPhoto(_ item: PhotosPickerItem) async {
        errorMessage = nil
        guard let data = try? await item.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data) else {
            errorMessage = "Couldn't load that image."
            return
        }
        let resized = uiImage.downscaled(maxDimension: 1024)
        guard let jpeg = resized.jpegData(compressionQuality: 0.7) else {
            errorMessage = "Couldn't process that image."
            return
        }
        guard jpeg.count <= 4 * 1024 * 1024 else {
            errorMessage = "Image is too large (max 4MB)."
            return
        }
        photoImage = Image(uiImage: resized)
        photoDataURL = "data:image/jpeg;base64,\(jpeg.base64EncodedString())"
    }

    private func create() {
        guard canSave, !saving else { return }
        saving = true
        errorMessage = nil
        Task {
            do {
                try await auth.addCat(name: trimmedName, photo: photoDataURL)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
            saving = false
        }
    }
}

private extension UIImage {
    // Proportionally shrink so the longest side is at most `maxDimension`.
    func downscaled(maxDimension: CGFloat) -> UIImage {
        let longestSide = max(size.width, size.height)
        guard longestSide > maxDimension else { return self }
        let scale = maxDimension / longestSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in draw(in: CGRect(origin: .zero, size: newSize)) }
    }
}

#Preview {
    NewCatView()
        .environment(AuthManager())
}
