// Owner: TBD (claim by editing this line)
//
// Modal sheet to share the cat's sitter guide link.
// Presented from HomeView. Replace the placeholder body with a real
// share UI (link copy, ShareLink, QR code, etc.).

import SwiftUI
import CoreImage.CIFilterBuiltins

struct ShareView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var auth
    @Environment(\.openURL) private var openURL

    @State private var isQRExpanded = false
    @State private var copied = false

    @State private var selectedDetent: PresentationDetent = .medium

    private var cat: Cat? { auth.currentCat }
    private var catName: String { cat?.name ?? "Your cat" }
    private var shareURLString: String {
        if let token = cat?.shareToken {
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

    private func openShare(_ urlString: String) {
        if let url = URL(string: urlString) { openURL(url) }
    }

    private func enc(_ string: String) -> String {
        string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    // HEADER
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(catName.uppercased())'S CARE GUIDE")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(.saveBg).opacity(0.6))
                                .tracking(0.8)

                            Text("Share the link")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color(.saveBg))
                        }

                        Spacer()

                        Button(action: { dismiss() }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 44, height: 44)
                                    .shadow(color: .black.opacity(0.08), radius: 4, y: 2)

                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(.saveBg))
                            }
                        }
                    }
                    .padding(.top,20)
                    .padding(.bottom, 4)

                    Text("Sitters open this in any browser. No app install on their side.")
                        .font(.footnote)
                        .foregroundColor(Color(.saveBg))

                    // COPY LINK
                    HStack(spacing: 12) {
                        Image(systemName: "link")
                            .font(.system(size: 15))
                            .foregroundColor(Color(.saveBg).opacity(0.5))

                        Text(shareDisplayURL)
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(Color(.saveBg))
                            .lineLimit(1)
                            .truncationMode(.tail)

                        Spacer()

                        Button(action: {
                            UIPasteboard.general.string = shareURLString

                            withAnimation(.spring(response: 0.3)) {
                                copied = true
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    copied = false
                                }
                            }
                        }) {
                            Text(copied ? "Copied!" : "Copy")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(
                                            copied
                                            ? Color(.bubbleSelectedBg)
                                            : Color(.saveBg)
                                        )
                                )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white.opacity(0.7))
                    )

                    // PREVIEW BUTTON
                    Button {
                        if let url = shareURL { openURL(url) }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "eye")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Color(.bubbleSelectedBg))

                            Text("Open it in a new tab — see what the sitter sees")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(.bubbleSelectedBorder))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(.bubbleSelectedBg).opacity(0.12))
                        )
                    }

                    // SHARE OPTIONS
                    HStack(spacing: 0) {
                        Button {
                            openShare("https://wa.me/?text=\(enc(shareMessage))")
                        } label: {
                            ShareIconButton(icon: "phone.fill", label: "WhatsApp",
                                            color: .green, bgColor: .green.opacity(0.15))
                        }
                        .buttonStyle(.plain)

                        Button {
                            openShare("https://t.me/share/url?url=\(enc(shareURLString))&text=\(enc("\(catName)'s care guide"))")
                        } label: {
                            ShareIconButton(icon: "paperplane.fill", label: "Telegram",
                                            color: .blue.opacity(0.7), bgColor: .blue.opacity(0.1))
                        }
                        .buttonStyle(.plain)

                        Button {
                            openShare("sms:&body=\(enc(shareMessage))")
                        } label: {
                            ShareIconButton(icon: "message.fill", label: "Messages",
                                            color: Color(.bubbleSelectedBg), bgColor: Color(.bubbleSelectedBg).opacity(0.15))
                        }
                        .buttonStyle(.plain)

                        Button {
                            openShare("mailto:?subject=\(enc("\(catName)'s Care Guide"))&body=\(enc(shareMessage))")
                        } label: {
                            ShareIconButton(icon: "envelope.fill", label: "Mail",
                                            color: .indigo, bgColor: .indigo.opacity(0.1))
                        }
                        .buttonStyle(.plain)

                        ShareLink(item: shareURL ?? URL(string: "https://meownotes.teztun.uz")!,
                                  message: Text(shareMessage)) {
                            ShareIconButton(icon: "ellipsis", label: "More",
                                            color: Color(.saveBg).opacity(0.5), bgColor: Color(.saveBg).opacity(0.08))
                        }
                    }

                    // QR DROPDOWN
                    VStack(spacing: 0) {
                        Button(action: {
                            withAnimation(.spring(response: 0.35)) {
                                isQRExpanded.toggle()

                                // EXPAND SHEET
                                selectedDetent = isQRExpanded
                                    ? .large
                                    : .medium
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "qrcode")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(Color(.saveBg))

                                Text("In person · show a QR")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color(.saveBg))

                                Spacer()

                                Image(systemName: isQRExpanded ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color(.saveBg).opacity(0.5))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                        }

                        if isQRExpanded {
                            Divider()
                                .padding(.horizontal, 16)

                            if let qr = qrImage(from: shareURLString) {
                                Image(uiImage: qr)
                                    .interpolation(.none)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 220, height: 220)
                                    .padding(.top, 24)
                            }

                            Text("Point a phone at this and they'll get the guide instantly.")
                                .font(.footnote)
                                .foregroundStyle(Color(.saveBg))
                                .padding(20)
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white.opacity(0.55))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color(.saveBg).opacity(0.1), lineWidth: 1)
                            )
                    )

                    // ROTATE LINK
                    HStack(spacing: 16) {
                        Text("Need to cut off access? Rotate to a fresh link — the old one stops working.")
                            .font(.system(size: 13))
                            .foregroundColor(Color(.saveBg).opacity(0.6))
                            .fixedSize(horizontal: false, vertical: true)

                        Button("Rotate") {

                        }
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

                    // DONE
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.saveBg))
                            )
                    }
                }
                .padding()
            }
            .presentationBackground(Color(.background))
            .presentationDetents(
                [.medium, .large],
                selection: $selectedDetent
            )
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    ShareView()
        .environment(AuthManager())
}
