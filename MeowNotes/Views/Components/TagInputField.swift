import SwiftUI

// The "add your own" input row shared across the care sheets: a rounded text
// field that highlights while focused, plus a filled "Add" button that greys
// out when the field is blank. Submitting from the keyboard adds too.
struct TagInputField: View {
    let placeholder: String
    @Binding var text: String
    var onAdd: () -> Void

    @FocusState private var isFocused: Bool

    private var isBlank: Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        HStack(spacing: 12) {
            TextField(placeholder, text: $text)
                .focused($isFocused)
                .submitLabel(.done)
                .onSubmit(add)
                .foregroundStyle(Color(.text))
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(Color("AddBg"), in: RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isFocused ? Color(.bubbleSelectedBg) : Color(.bubbleBorder), lineWidth: 1)
                )
                .animation(.easeInOut, value: isFocused)

            Button(action: add) {
                Text("Add")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .frame(height: 48)
                    .background(isBlank ? Color.gray : Color(.saveBg))
                    .clipShape(Capsule())
            }
            .disabled(isBlank)
        }
    }

    private func add() {
        guard !isBlank else { return }
        Haptics.tap()
        onAdd()
    }
}

#Preview {
    @Previewable @State var text = ""
    return TagInputField(placeholder: "Add your own…", text: $text) {}
        .padding()
        .background(Color("AppBg"))
}
