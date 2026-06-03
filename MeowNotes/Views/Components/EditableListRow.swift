import SwiftUI

// A tap-to-edit row used in the care sheets: shows its text, and on tap turns
// into an inline field. It binds the text directly, so an edit is reflected
// immediately — saving works even if the field is still focused. Pick the
// leading accessory (a dot, or a red warning).
struct EditableListRow: View {
    enum Accessory { case dot, warning }

    @Binding var text: String
    var accessory: Accessory = .dot
    var limit: Int = 200
    let onRemove: () -> Void

    @State private var isEditing = false
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 8) {
            leadingAccessory

            Group {
                if isEditing {
                    TextField("Edit", text: $text)
                        .textFieldStyle(.plain)
                        .focused($isFocused)
                        .submitLabel(.done)
                        .onSubmit { isFocused = false }
                        .characterLimit(limit, $text)
                } else {
                    Text(text)
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
                .accessibilityHidden(true)

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
        .onChange(of: isEditing) { _, editing in
            if editing { DispatchQueue.main.async { isFocused = true } }
        }
        .onChange(of: isFocused) { _, focused in
            if !focused { isEditing = false }
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
}

#Preview {
    @Previewable @State var a = "Hides under the bed"
    @Previewable @State var b = "Allergic to chicken"
    return VStack(spacing: 10) {
        EditableListRow(text: $a, accessory: .dot, onRemove: {})
        EditableListRow(text: $b, accessory: .warning, onRemove: {})
    }
    .padding()
    .background(Color("AppBg"))
}
