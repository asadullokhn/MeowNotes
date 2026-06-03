import SwiftUI
import UIKit

// Facebook-style interactive crop. The crop window is a fixed aspect (the photo
// well's shape); the user pans and pinch-zooms the photo behind it to frame the
// cat's face, then "Use photo" exports exactly the window.
struct PhotoCropView: View {
    let image: UIImage
    let aspect: CGFloat            // crop window width / height
    var onCancel: () -> Void
    var onCrop: (UIImage) -> Void

    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    private let minScale: CGFloat = 1
    private let maxScale: CGFloat = 5

    var body: some View {
        GeometryReader { geo in
            // The crop window fills the width and takes its height from the aspect.
            let cropW = geo.size.width
            let cropH = cropW / max(aspect, 0.1)
            // Size the photo to exactly fill the window at scale 1 (aspect fill),
            // so it always covers the window and there's never an empty edge.
            let fitScale = max(cropW / image.size.width, cropH / image.size.height)
            let baseW = image.size.width * fitScale
            let baseH = image.size.height * fitScale

            // Keep the photo covering the window: clamp the pan to the overscan.
            let clampOffset: () -> Void = {
                let maxX = max(0, (baseW * scale - cropW) / 2)
                let maxY = max(0, (baseH * scale - cropH) / 2)
                offset.width = min(max(offset.width, -maxX), maxX)
                offset.height = min(max(offset.height, -maxY), maxY)
            }

            // Export just the window. Work in the image's own point space and let
            // UIGraphicsImageRenderer handle scale + orientation via draw(in:).
            let performCrop: () -> Void = {
                let f = fitScale * scale
                let srcX = (baseW * scale / 2 - cropW / 2 - offset.width) / f
                let srcY = (baseH * scale / 2 - cropH / 2 - offset.height) / f
                let srcRect = CGRect(x: srcX, y: srcY, width: cropW / f, height: cropH / f)
                let renderer = UIGraphicsImageRenderer(size: srcRect.size)
                let cropped = renderer.image { _ in
                    image.draw(in: CGRect(x: -srcRect.origin.x, y: -srcRect.origin.y,
                                          width: image.size.width, height: image.size.height))
                }
                onCrop(cropped)
            }

            ZStack {
                Color.black.ignoresSafeArea()

                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: baseW, height: baseH)
                    .scaleEffect(scale)
                    .offset(offset)
                    .frame(width: cropW, height: cropH)
                    .clipped()
                    .overlay(
                        Rectangle().stroke(Color.white.opacity(0.85), lineWidth: 2)
                    )
                    .contentShape(Rectangle())
                    .gesture(
                        SimultaneousGesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = min(max(lastScale * value, minScale), maxScale)
                                    clampOffset()
                                }
                                .onEnded { _ in lastScale = scale; clampOffset(); lastOffset = offset },
                            DragGesture()
                                .onChanged { value in
                                    offset = CGSize(width: lastOffset.width + value.translation.width,
                                                    height: lastOffset.height + value.translation.height)
                                    clampOffset()
                                }
                                .onEnded { _ in lastOffset = offset }
                        )
                    )
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)

                VStack {
                    HStack {
                        Button("Cancel") { onCancel() }
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .padding()

                    Spacer()

                    VStack(spacing: 14) {
                        Text("Drag to reposition · pinch to zoom")
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.7))
                        Button(action: performCrop) {
                            Text("Use photo")
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color(.saveBg))
                                .clipShape(RoundedRectangle(cornerRadius: 26))
                        }
                    }
                    .padding(20)
                }
            }
        }
    }
}
