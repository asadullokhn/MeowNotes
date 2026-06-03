import SwiftUI

// The nav-bar Save button shared across the edit sheets. It reads in the app's
// accent color once there are unsaved changes, and sits dimmed when there's
// nothing to save — so "is there anything to save?" is visible at a glance.
struct SaveToolbarButton: View {
    var saving: Bool
    var hasChanges: Bool
    var disabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            if saving {
                ProgressView()
            } else {
                Text("Save")
                    .fontWeight(.semibold)
                    .foregroundStyle(hasChanges ? Color(.bubbleSelectedBg) : Color(.text).opacity(0.35))
            }
        }
        .disabled(saving || disabled)
    }
}
