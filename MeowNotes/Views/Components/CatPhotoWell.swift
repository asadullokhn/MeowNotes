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
    @State private var cropTarget: CropTarget?
    @State private var wellWidth: CGFloat = 0

    // The crop window matches the well's shape, so what you frame is what shows.
    private var cropAspect: CGFloat {
        wellWidth > 0 ? wellWidth / height : (fillWidth ? 1.7 : 1)
    }

    var body: some View {
        // Read the main-actor @State here in `body` (which is main-actor), then
        // hand plain Sendable values to the label's child view. PhotosPicker's
        // @escaping label closure is nonisolated under strict concurrency, so it
        // can't touch `pickedImage` or build a view directly — but capturing
        // already-read values is fine.
        let preview = pickedImage
        let actionLabelText = (pickedImage != nil || !existingPhotoURL.isEmpty) ? "Change photo" : "Upload photo"
        return PhotosPicker(selection: $item, matching: .images) {
            PhotoWellLabel(
                preview: preview,
                existingPhotoURL: existingPhotoURL,
                showActionLabel: showActionLabel,
                actionLabelText: actionLabelText,
                fillWidth: fillWidth,
                height: height,
                cornerRadius: cornerRadius
            )
        }
        .buttonStyle(.plain)
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear { wellWidth = proxy.size.width }
                    .onChange(of: proxy.size.width) { _, w in wellWidth = w }
            }
        )
        .onChange(of: item) { _, newItem in
            guard let newItem else { return }
            Task { await load(newItem) }
        }
        .fullScreenCover(item: $cropTarget) { target in
            PhotoCropView(
                image: target.image,
                aspect: cropAspect,
                onCancel: { cropTarget = nil; item = nil },
                onCrop: { cropped in commit(cropped); cropTarget = nil; item = nil }
            )
        }
    }

    // Load the picked image and hand it to the cropper. Downscale a little first
    // so panning/zooming a huge photo stays smooth; the final downscale + encode
    // happens in commit() once the crop is confirmed.
    private func load(_ photoItem: PhotosPickerItem) async {
        errorMessage = nil
        guard let data = try? await photoItem.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data) else {
            errorMessage = "Couldn't load that image."
            return
        }
        cropTarget = CropTarget(image: uiImage.downscaled(maxDimension: 2048))
    }

    // Encode the cropped image as a base64 data URL, mirroring the web's pipeline.
    private func commit(_ cropped: UIImage) {
        let resized = cropped.downscaled(maxDimension: 1024)
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

// A picked image awaiting crop. Identifiable so it can drive a fullScreenCover.
private struct CropTarget: Identifiable {
    let id = UUID()
    let image: UIImage
}

// The picker's label content as its own view, so its body is main-actor isolated
// and can freely build `CachedCatImage` and show the picked image.
private struct PhotoWellLabel: View {
    let preview: Image?
    let existingPhotoURL: String
    let showActionLabel: Bool
    let actionLabelText: String
    let fillWidth: Bool
    let height: CGFloat
    let cornerRadius: CGFloat

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.bubbleSectionBg)

            if let preview {
                preview.resizable().scaledToFill()
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            if showActionLabel {
                HStack(spacing: 6) {
                    Image(systemName: "camera.fill")
                    Text(actionLabelText)
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
