import SwiftUI

// The nav-bar Save button shared across the edit sheets. It reads in the app's
// accent color once there are unsaved changes, and sits dimmed when there's
// nothing to save — so "is there anything to save?" is visible at a glance.
struct SaveToolbarButton: View {
    @Environment(\.dismiss) var dismiss
    var saving: Bool
    var hasChanges: Bool
    var disabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        if hasChanges {
            Button(action: { Haptics.tap(.medium); action() }) {
                if saving {
                    ProgressView()
                } else {
                    Text("Save")
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(.saveButtonText))
                }
            }
            .disabled(saving || disabled)
            // The dirty state is otherwise conveyed only by color — announce it.
            .accessibilityValue(hasChanges ? "Unsaved changes" : "No changes")
            .tint(Color(.saveBg))
            .buttonStyle(.glassProminent)
        }
        else  {
            Button(action: {dismiss()}) {
                Text("Save")
                    .fontWeight(.regular)
                    .foregroundStyle(Color(.text))
            }
            
        }
    }
}
