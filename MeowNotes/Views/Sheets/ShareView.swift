// Owner: TBD (claim by editing this line)
//
// Modal sheet to share the cat's sitter guide link: QR on top, the link to copy,
// and one native Share button. Presented from HomeView.

import SwiftUI
import CoreImage.CIFilterBuiltins

struct ShareView: View {
    @Environment(AuthManager.self) private var auth
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("appearance") private var appearance = AppAppearance.system.rawValue

    @State private var copied = false
    @State private var showPreview = false
    // Natural height of the header + content, measured so the sheet hugs its
    // content instead of stretching to a half-empty .large detent.
    @State private var sheetHeight: CGFloat = 0
    // Token fetched/created on appear. A brand-new cat (every guest's first cat)
    // has no share row yet, so we lazily create one via the API.
    @State private var fetchedToken: String?
    @State private var loadingLink = false

    // Measured height + a buffer for the home-indicator safe area; a sensible
    // default seeds the first frame before measurement lands.
    private var resolvedSheetHeight: CGFloat { sheetHeight > 0 ? sheetHeight + 40 : 600 }

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

    // The app's effective light/dark, resolving "system" to the current scheme.
    private var previewTheme: String {
        switch AppAppearance(rawValue: appearance) {
        case .light: return "light"
        case .dark:  return "dark"
        default:     return colorScheme == .dark ? "dark" : "light"
        }
    }

    // In-app preview only: seed the guide's theme to match the owner's app via
    // ?theme= (read by the web guide's hash router as route.query.theme). Kept
    // off the shared/QR/copied link so each sitter still gets their own theme.
    private var previewURL: URL? {
        guard token != nil else { return nil }
        return URL(string: "\(shareURLString)?theme=\(previewTheme)")
    }

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
                    .background(heightReader)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // QR — top, always visible
                        if let qr = qrImage(from: shareURLString) {
                            Image(uiImage: qr)
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 240, height: 240)
                                .padding(16)
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
                        // Solid white in dark mode (0.7 reads gray there); keep the
                        // softer translucent white in light mode.
                        .background(RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white.opacity(colorScheme == .dark ? 1 : 0.7)))

                        // OPEN THE GUIDE IN AN IN-APP BROWSER (preview what the
                        // sitter sees, without leaving MeowNotes).
                        Button {
                            Haptics.tap()
                            showPreview = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "eye")
                                Text("Open preview")
                            }
                            .font(.headline)
                            .foregroundStyle(Color(.saveBg))
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(.saveBg), lineWidth: 1.5)
                            )
                        }
                        .disabled(!hasLink)

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
                    .background(heightReader)
                }
                .presentationBackground(Color(.background))
                .presentationDetents([.height(resolvedSheetHeight)])
                .presentationDragIndicator(.visible)
            }
            .onPreferenceChange(SheetHeightKey.self) { sheetHeight = $0 }
        }
        .task { await ensureLink() }
        .fullScreenCover(isPresented: $showPreview) {
            if let previewURL {
                SafariView(url: previewURL).ignoresSafeArea()
            }
        }
    }

    // Reports its container's height into SheetHeightKey; the key sums every
    // reader (header + content) so the sheet detent can match the total.
    private var heightReader: some View {
        GeometryReader { proxy in
            Color.clear.preference(key: SheetHeightKey.self, value: proxy.size.height)
        }
    }
}

private struct SheetHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

#Preview {
    ShareView()
        .environment(AuthManager())
}
