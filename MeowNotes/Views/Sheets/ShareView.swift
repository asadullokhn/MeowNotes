// Owner: TBD (claim by editing this line)
//
// Modal sheet to share the cat's sitter guide link.
// Presented from HomeView. Replace the placeholder body with a real
// share UI (link copy, ShareLink, QR code, etc.).

import SwiftUI

struct ShareView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var isQRExpanded = false
    @State private var copied = false

    @State private var selectedDetent: PresentationDetent = .medium

    let shareURL = "meownotes.teztun.uz/#/g/c-ffe7-6..."
    var catName = "gohan"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    // HEADER
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("GOHAN'S CARE GUIDE")
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

                        Text(shareURL)
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(Color(.saveBg))
                            .lineLimit(1)
                            .truncationMode(.tail)

                        Spacer()

                        Button(action: {
                            UIPasteboard.general.string = shareURL

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
                        ShareIconButton(
                            icon: "phone.fill",
                            label: "WhatsApp",
                            color: .green,
                            bgColor: .green.opacity(0.15)
                        )

                        ShareIconButton(
                            icon: "paperplane.fill",
                            label: "Telegram",
                            color: .blue.opacity(0.7),
                            bgColor: .blue.opacity(0.1)
                        )

                        ShareIconButton(
                            icon: "message.fill",
                            label: "Messages",
                            color: Color(.bubbleSelectedBg),
                            bgColor: Color(.bubbleSelectedBg).opacity(0.15)
                        )

                        ShareIconButton(
                            icon: "envelope.fill",
                            label: "Mail",
                            color: .indigo,
                            bgColor: .indigo.opacity(0.1)
                        )

                        ShareIconButton(
                            icon: "ellipsis",
                            label: "More",
                            color: Color(.saveBg).opacity(0.5),
                            bgColor: Color(.saveBg).opacity(0.08)
                        )
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

                            Image("barcode")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 220, height: 220)
                                .padding(.top, 24)

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
}
