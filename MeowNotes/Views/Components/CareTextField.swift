import SwiftUI
import UIKit

// A boxed text field with a focus-highlighting border, shared across the care
// editors so every inline input is the same size and lights up on focus.
struct CareTextField: View {
    let placeholder: String
    @Binding var text: String
    var axis: Axis = .horizontal
    var lineLimit: ClosedRange<Int> = 2...4
    var bold: Bool = false
    var keyboard: UIKeyboardType = .default
    var fill: Color = Color(.bubbleSectionBg)

    @FocusState private var focused: Bool

    var body: some View {
        field
            .font(.body.weight(bold ? .semibold : .regular))
            .foregroundStyle(Color(.text))
            .textInputAutocapitalization(.sentences)
            .keyboardType(keyboard)
            .focused($focused)
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(fill, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(focused ? Color(.bubbleSelectedBg) : Color(.bubbleBorder), lineWidth: 1)
            )
            .animation(.easeInOut(duration: 0.15), value: focused)
    }

    @ViewBuilder
    private var field: some View {
        if axis == .vertical {
            TextField(placeholder, text: $text, axis: .vertical)
                .lineLimit(lineLimit)
        } else {
            TextField(placeholder, text: $text)
        }
    }
}
