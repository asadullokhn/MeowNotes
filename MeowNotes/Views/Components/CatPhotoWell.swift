//
//  CatPhotoWell.swift
//  MeowNotes
//
//  Tappable photo picker used by the New Cat and Basics editors. Owns the
//  PhotosPicker so its label is built inline (no main-actor computed properties
//  referenced from the picker closure, which Swift 6 rejects). Reports the
//  picked image back as a base64 data URL.
//

import SwiftUI
import PhotosUI
import UIKit

struct CatPhotoWell: View {
    let existingPhotoURL: String
    @Binding var dataURL: String?
    @Binding var errorMessage: String?
    var fillWidth: Bool = false
    var height: CGFloat = 80
    var cornerRadius: CGFloat = 18
    var showActionLabel: Bool = false

    @State private var item: PhotosPickerItem?
    @State private var pickedImage: Image?

    var body: some View {
        PhotosPicker(selection: $item, matching: .images) {
            ZStack(alignment: .bottom) {
                Color(.bubbleSectionBg)

                if let pickedImage {
                    pickedImage.resizable().scaledToFill()
                } else if !existingPhotoURL.isEmpty {
                    CachedCatImage(existingPhotoURL) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.clear
                    }
                } else {
                    VStack(spacing: 4) {
                        Image(systemName: "camera.fill").font(.system(size: 18))
                        Text("PHOTO").font(.system(size: 9, weight: .semibold)).tracking(0.5)
                    }
                    .foregroundStyle(Color(.text).opacity(0.45))
                }

                if showActionLabel {
                    HStack(spacing: 6) {
                        Image(systemName: "camera.fill")
                        Text(pickedImage != nil || !existingPhotoURL.isEmpty ? "Change photo" : "Upload photo")
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(.black.opacity(0.45))
                }
            }
            .frame(width: fillWidth ? nil : height, height: height)
            .frame(maxWidth: fillWidth ? .infinity : nil)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color(.bubbleBorder), lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
        .buttonStyle(.plain)
        .onChange(of: item) { _, newItem in
            guard let newItem else { return }
            Task { await load(newItem) }
        }
    }

    private func load(_ photoItem: PhotosPickerItem) async {
        errorMessage = nil
        guard let data = try? await photoItem.loadTransferable(type: Data.self),
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
        pickedImage = Image(uiImage: resized)
        dataURL = "data:image/jpeg;base64,\(jpeg.base64EncodedString())"
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
