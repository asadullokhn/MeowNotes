//
//  AddBubble.swift
//  MeowNotes
//
//  Created by Orenz on 26/05/26.
//

import SwiftUI

struct AddBubble: View {
    let text: String
    // Already added: dimmed and non-tappable. Drives the "greyed when selected"
    // state the care sheets used to hand-roll.
    var isSelected: Bool = false
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
            .foregroundColor(Color("TextColor"))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color("BubbleBg"))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color("BubbleBorder").opacity(1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(isSelected)
        .opacity(isSelected ? 0.4 : 1)
    }
}
