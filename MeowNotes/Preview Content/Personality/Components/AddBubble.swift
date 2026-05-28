//
//  AddBubble.swift
//  MeowNotes
//
//  Created by Orenz on 26/05/26.
//

import SwiftUI

struct AddBubble: View {
    let text: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 10, weight: .bold))

                Text(text)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(.blue)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.blue.opacity(0.12))
            .clipShape(Capsule())
        }
    }
}
