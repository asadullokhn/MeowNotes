//
//  CustomAddBubble.swift
//  MeowNotes
//
//  Created by Orenz on 26/05/26.
//

import SwiftUI

struct CustomAddBubble: View {
    let text: String
    let onAdd: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Button(action: onAdd) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 10, weight: .bold))
                    
                    Text(text)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }

            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
            }
        }
        .foregroundColor(.blue)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.blue.opacity(0.12))
        .clipShape(Capsule())
    }
}
