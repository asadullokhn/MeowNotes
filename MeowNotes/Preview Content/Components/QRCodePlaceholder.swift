//
//  QRCodePlaceholder.swift
//  MeowNotes
//
//  Created by Yimei Winata on 28/05/26.
//
import SwiftUI

struct QRCodePlaceholder: View {
    var body: some View {
        VStack(spacing: 12) {
            // Simple QR pattern drawn with SwiftUI
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .frame(width: 160, height: 160)
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
 
                // Corner squares
                VStack(spacing: 80) {
                    HStack(spacing: 80) {
                        QRCornerSquare()
                        QRCornerSquare()
                    }
                    HStack(spacing: 80) {
                        QRCornerSquare()
                        Spacer().frame(width: 24, height: 24)
                    }
                }
 
                // Center dots (simplified)
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        ForEach(0..<4) { _ in
                            Rectangle()
                                .fill(Color(.saveBg).opacity(0.2))
                                .frame(width: 6, height: 6)
                        }
                    }
                    HStack(spacing: 4) {
                        ForEach(0..<4) { _ in
                            Rectangle()
                                .fill(Color(.saveBg).opacity(0.3))
                                .frame(width: 6, height: 6)
                        }
                    }
                    HStack(spacing: 4) {
                        ForEach(0..<4) { _ in
                            Rectangle()
                                .fill(Color(.saveBg).opacity(0.2))
                                .frame(width: 6, height: 6)
                        }
                    }
                }
            }
 
            Text("Point camera to scan")
                .font(.system(size: 12))
                .foregroundColor(Color(.saveBg).opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }
}
