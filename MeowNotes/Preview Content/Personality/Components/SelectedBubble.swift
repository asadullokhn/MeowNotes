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
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.blue)
        .clipShape(Capsule())
    }
}
