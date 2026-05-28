//
//  SelectedBubble.swift
//  MeowNotes
//
//  Created by Orenz on 26/05/26.
//

import SwiftUI

struct SelectedBubble: View {
    let text: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Text(text)
                .font(.subheadline)
                .fontWeight(.medium)

            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color.white)
                    .padding(6)
                    .background(Color("XBtnBg"))
                    .clipShape(Circle())
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color("BubbleSelectedBg"))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color("BubbleSelectedBorder").opacity(1), lineWidth: 1)
        )
    }
}
