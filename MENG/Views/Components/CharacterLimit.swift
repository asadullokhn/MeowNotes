import SwiftUI

extension View {
    // Cap a field's length, trimming extra input (including pastes) as it arrives.
    // Keeps text inputs from accepting unreasonably long data.
    func characterLimit(_ limit: Int, _ text: Binding<String>) -> some View {
        onChange(of: text.wrappedValue) { _, newValue in
            if newValue.count > limit {
                text.wrappedValue = String(newValue.prefix(limit))
            }
        }
    }
}
