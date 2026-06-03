import SwiftUI

// A tap-to-edit row used in the care sheets: shows its text, and on tap turns
// into an inline field that commits on submit. Merges the former
// SelectedBubbleEdit (a small dot) and SelectedBubbleCautionEdit (a red
// warning) into one component — pick the leading accessory.
struct EditableListRow: View {
    enum Accessory { case dot, warning }

    @State private var isEditing = false
    @State private var editedText: String
    @FocusState private var isFocused: Bool

    let accessory: Accessory
    let onRemove: () -> Void
    let onSave: (String) -> Void

    init(
        text: String,
        accessory: Accessory = .dot,
        onRemove: @escaping () -> Void,
        onSave: @escaping (String) -> Void
    ) {
        _editedText = State(initialValue: text)
        self.accessory = accessory
        self.onRemove = onRemove
        self.onSave = onSave
    }

    var body: some View {
        HStack(spacing: 8) {
            leadingAccessory

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

            RemoveCircleButton(size: 26, action: onRemove)
        }
        .foregroundStyle(Color(.text))
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.bubbleBg))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isFocused ? Color(.bubbleSelectedBg) : Color(.bubbleBorder), lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.15), value: isFocused)
        .contentShape(Rectangle())
        .onTapGesture { isEditing = true }
        .onChange(of: isEditing) { _, newValue in
            if newValue {
                DispatchQueue.main.async { isFocused = true }
            }
        }
    }

    @ViewBuilder
    private var leadingAccessory: some View {
        switch accessory {
        case .dot:
            Circle()
                .fill(Color(.bubbleSelectedBg))
                .frame(width: 7, height: 7)
        case .warning:
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.6))
                    .frame(width: 32, height: 32)
                Image(systemName: "exclamationmark")
                    .foregroundStyle(.white)
                    .font(.system(size: 14, weight: .bold))
            }
        }
    }

    private func save() {
        isEditing = false
        isFocused = false
        onSave(editedText.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}

#Preview {
    VStack(spacing: 10) {
        EditableListRow(text: "Hides under the bed", accessory: .dot, onRemove: {}, onSave: { _ in })
        EditableListRow(text: "Allergic to chicken", accessory: .warning, onRemove: {}, onSave: { _ in })
    }
    .padding()
    .background(Color("AppBg"))
}
