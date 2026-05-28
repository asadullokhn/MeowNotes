//
//  SelectedBubbleLongEdit.swift
//  MeowNotes
//
//  Created by Orenz on 28/05/26.
//

import SwiftUI

struct SelectedBubbleLongEdit: View {
    @State private var isEditing = false
    @State private var editedText: String
    @FocusState private var isFocused: Bool

    let onRemove: () -> Void
    let onSave: (String) -> Void

    init(
        text: String,
        onRemove: @escaping () -> Void,
        onSave: @escaping (String) -> Void
    ) {
        _editedText = State(initialValue: text)
        self.onRemove = onRemove
        self.onSave = onSave
    }

    var body: some View {
        HStack(spacing: 8) {

            Circle()
                .fill(Color("BubbleSelectedBg"))
                .frame(width: 7, height: 7)

            Group {
                if isEditing {
                    TextField("Edit", text: $editedText)
                        .textFieldStyle(.plain)
                        .focused($isFocused)
                        .submitLabel(.done)
                        .onSubmit { save() }
                } else {
                    Text(editedText)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .truncationMode(.tail)
                }
            }
            .layoutPriority(1)

            Spacer(minLength: 0)

            Image(systemName: "pencil")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gray.opacity(0.8))

            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color("TextColor"))
                    .padding(6)
                    .background(Color("BubbleBorder"))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .foregroundColor(Color("TextColor"))
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("BubbleBg"))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color("BubbleBorder"), lineWidth: 1)
        )
        .contentShape(Rectangle())

        .onTapGesture {
            enterEdit()
        }

        .onChange(of: isEditing) { _, newValue in
            if newValue {
                DispatchQueue.main.async {
                    isFocused = true
                }
            }
        }
    }

    private func enterEdit() {
        isEditing = true
    }

    private func save() {
        isEditing = false
        isFocused = false
        onSave(editedText.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}
