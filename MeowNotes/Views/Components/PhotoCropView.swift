import SwiftUI
import UIKit

// Facebook-style interactive crop. The crop window is a fixed aspect (the photo
// well's shape); the user pans and pinch-zooms the photo to frame the cat's
// face. The area outside the window stays visible but dimmed, so it's clear
// what will be cut off, then "Use photo" exports exactly the window.
struct PhotoCropView: View {
    let image: UIImage
    let aspect: CGFloat            // crop window width / height
    var onCancel: () -> Void
    var onCrop: (UIImage) -> Void

    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    // Layout derived once the crop area is measured (so the controls, which live
    // outside the GeometryReader to respect the safe area, can still export).
    @State private var cropSize: CGSize = .zero
    @State private var baseSize: CGSize = .zero
    @State private var fitScale: CGFloat = 1

    private let minScale: CGFloat = 1
    private let maxScale: CGFloat = 5

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black

                // The full photo — not clipped — so the dimmed overscan shows
                // exactly what falls outside the crop window.
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: baseSize.width, height: baseSize.height)
                    .scaleEffect(scale)
                    .offset(offset)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)

                // Dim everything outside the crop window.
                Color.black.opacity(0.55)
                    .reverseMask {
                        Rectangle()
                            .frame(width: cropSize.width, height: cropSize.height)
                            .position(x: geo.size.width / 2, y: geo.size.height / 2)
                    }
                    .allowsHitTesting(false)

                // Crop window outline.
                Rectangle()
                    .stroke(Color.white.opacity(0.9), lineWidth: 2)
                    .frame(width: cropSize.width, height: cropSize.height)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                    .allowsHitTesting(false)

                // Full-area gesture layer so dragging anywhere pans/zooms. Empty
                // Spacers in the controls stack above let drags fall through here.
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(gesture)

                // Controls, padded by the real device insets the GeometryReader
                // reports (it ignores the safe area, so safeAreaInsets are the
                // actual notch/home-indicator insets). Keeps Cancel below the
                // notch and Use photo above the home indicator, both tappable —
                // safeAreaInset resolved to zero here because the canvas is
                // full-bleed, dropping Cancel under the status bar.
                VStack {
                    HStack {
                        Button("Cancel") { onCancel() }
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    Spacer()
                    VStack(spacing: 14) {
                        Text("Drag to reposition · pinch to zoom")
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.7))
                        Button(action: crop) {
                            Text("Use photo")
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color(.saveBg))
                                .clipShape(RoundedRectangle(cornerRadius: 26))
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, geo.safeAreaInsets.top + 8)
                .padding(.bottom, geo.safeAreaInsets.bottom + 12)
            }
            .onAppear { setup(geo.size) }
            .onChange(of: geo.size) { _, newSize in setup(newSize) }
        }
        .ignoresSafeArea()
    }

    private var gesture: some Gesture {
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
    }

    // Size the photo to exactly fill the window at scale 1 (aspect fill), so it
    // always covers the window and there's never an empty edge inside it.
    private func setup(_ size: CGSize) {
        let cropW = size.width
        let cropH = cropW / max(aspect, 0.1)
        cropSize = CGSize(width: cropW, height: cropH)
        let fit = max(cropW / image.size.width, cropH / image.size.height)
        fitScale = fit
        baseSize = CGSize(width: image.size.width * fit, height: image.size.height * fit)
        clampOffset()
    }

    // Keep the photo covering the window: clamp the pan to the overscan.
    private func clampOffset() {
        let maxX = max(0, (baseSize.width * scale - cropSize.width) / 2)
        let maxY = max(0, (baseSize.height * scale - cropSize.height) / 2)
        offset.width = min(max(offset.width, -maxX), maxX)
        offset.height = min(max(offset.height, -maxY), maxY)
    }

    // Export just the window. Work in the image's own point space and let
    // UIGraphicsImageRenderer handle scale + orientation via draw(in:).
    private func crop() {
        guard cropSize.width > 0, fitScale > 0 else { return }
        let f = fitScale * scale
        let srcX = (baseSize.width * scale / 2 - cropSize.width / 2 - offset.width) / f
        let srcY = (baseSize.height * scale / 2 - cropSize.height / 2 - offset.height) / f
        let srcRect = CGRect(x: srcX, y: srcY, width: cropSize.width / f, height: cropSize.height / f)
        let renderer = UIGraphicsImageRenderer(size: srcRect.size)
        let cropped = renderer.image { _ in
            image.draw(in: CGRect(x: -srcRect.origin.x, y: -srcRect.origin.y,
                                  width: image.size.width, height: image.size.height))
        }
        onCrop(cropped)
    }
}

private extension View {
    // Punch the mask shape OUT of the view (the inverse of `.mask`), so a scrim
    // dims everything except the crop window.
    func reverseMask<Mask: View>(@ViewBuilder _ mask: () -> Mask) -> some View {
        self.mask {
            Rectangle()
                .overlay { mask().blendMode(.destinationOut) }
                .compositingGroup()
        }
    }
}
