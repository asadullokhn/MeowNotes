// Owner: TBD (claim by editing this line)
//
// Modal sheet to share the cat's sitter guide link: QR on top, the link to copy,
// and one native Share button. Presented from HomeView.

import SwiftUI
import CoreImage.CIFilterBuiltins

struct ShareView: View {
    @Environment(AuthManager.self) private var auth

    @State private var copied = false
    // Token fetched/created on appear. A brand-new cat (every guest's first cat)
    // has no share row yet, so we lazily create one via the API.
    @State private var fetchedToken: String?
    @State private var loadingLink = false

    private var cat: Cat? { auth.currentCat }
    private var catName: String { cat?.name ?? "Your cat" }
    private var token: String? { fetchedToken ?? cat?.shareToken }
    private var hasLink: Bool { token != nil }
    private var shareURLString: String {
        if let token {
            return "https://meownotes.teztun.uz/#/g/\(token)"
        }
        return "https://meownotes.teztun.uz"
    }
    private var shareURL: URL? { URL(string: shareURLString) }
    private var shareDisplayURL: String { shareURLString.replacingOccurrences(of: "https://", with: "") }
    private var shareMessage: String { "Here's \(catName)'s care guide: \(shareURLString)" }

    private func qrImage(from string: String) -> UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        guard let output = filter.outputImage?.transformed(by: CGAffineTransform(scaleX: 10, y: 10)),
              let cgImage = CIContext().createCGImage(output, from: output.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    // Fetch (creating if needed) the cat's share link the first time the sheet opens.
    private func ensureLink() async {
        guard fetchedToken == nil, cat?.shareToken == nil, let cat else { return }
        loadingLink = true
        fetchedToken = try? await auth.shareLink(catID: cat.id)
        loadingLink = false
    }

    // Rotate to a fresh link (the "Refresh" action) — the old one stops working.
    private func rotateLink() async {
        guard let cat, !loadingLink else { return }
        loadingLink = true
        if let token = try? await auth.rotateShareLink(catID: cat.id) {
            fetchedToken = token
            VoiceOver.announce("New link created. The old link no longer works.")
        }
        loadingLink = false
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // HEADER — swipe down (drag indicator) to dismiss.
                Text("Share the link")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(.text))
                    .accessibilityAddTraits(.isHeader)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 24)
                    .padding(.bottom, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // QR — top, always visible
                        if let qr = qrImage(from: shareURLString) {
                            Image(uiImage: qr)
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 180, height: 180)
                                .padding(14)
                                .background(Color.white, in: RoundedRectangle(cornerRadius: 24))
                                .frame(maxWidth: .infinity)
                                .opacity(hasLink ? 1 : 0.4)
                        }

                        // LINK
                        HStack(spacing: 12) {
                            Image(systemName: "link")
                                .font(.system(size: 15))
                                .foregroundColor(Color(.saveBg).opacity(0.5))

                            Text(hasLink ? shareDisplayURL : "Generating link…")
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(Color(.saveBg).opacity(hasLink ? 1 : 0.5))
                                .lineLimit(1)
                                .truncationMode(.middle)

                            Spacer()

                            Button {
                                UIPasteboard.general.string = shareURLString
                                Haptics.tap()
                                VoiceOver.announce("Link copied")
                                withAnimation(.spring(response: 0.3)) { copied = true }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation { copied = false }
                                }
                            } label: {
                                Text(copied ? "Copied!" : "Copy")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Capsule().fill(copied ? Color(.bubbleSelectedBg) : Color(.saveBg)))
                            }
                            .disabled(!hasLink)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.7)))

                        // ONE NATIVE SHARE BUTTON
                        ShareLink(item: shareURL ?? URL(string: "https://meownotes.teztun.uz")!,
                                  message: Text(shareMessage)) {
                            HStack(spacing: 10) {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share link")
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color(.saveBg), in: RoundedRectangle(cornerRadius: 16))
                        }
                        .disabled(!hasLink)

                        // REFRESH LINK
                        HStack(spacing: 16) {
                            Text("Need to cut off access? Refresh for a new link — the old one stops working.")
                                .font(.system(size: 13))
                                .foregroundColor(Color(.text).opacity(0.6))
                                .fixedSize(horizontal: false, vertical: true)

                            Button {
                                Task { await rotateLink() }
                            } label: {
                                if loadingLink {
                                    ProgressView()
                                } else {
                                    Text("Refresh")
                                    Image(systemName: "arrow.clockwise")
                                }
                            }
                            .disabled(loadingLink || !hasLink)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(.saveBg))
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.07), radius: 4, y: 2)
                            )
                        }
                    }
                    .padding()
                }
                .presentationBackground(Color(.background))
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
        .task { await ensureLink() }
    }
}

#Preview {
    ShareView()
        .environment(AuthManager())
}
