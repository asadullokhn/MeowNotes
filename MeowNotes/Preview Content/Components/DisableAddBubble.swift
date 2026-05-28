//
//  DisableAddBubble.swift
//  MeowNotes
//
//  Created by Orenz on 28/05/26.
//

import SwiftUI

struct DisableAddBubble: View {
    let text: String
    let onAdd: () -> Void
    var disabled: Bool = false

    var body: some View {
        Button(action: {
            if !disabled { onAdd() }
        }) {
            Text(text)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(disabled ? Color.gray.opacity(0.4) : Color("BubbleBg"))
                .foregroundColor(disabled ? Color.gray.opacity(0.8) : Color("TextColor"))
                .clipShape(Capsule())
        }
        .disabled(disabled)
        .animation(nil, value: disabled)
        
    }
}
