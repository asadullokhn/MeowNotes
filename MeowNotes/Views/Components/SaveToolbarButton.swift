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
        Button(action: { Haptics.tap(.medium); action() }) {
            if saving {
                ProgressView()
            } else if hasChanges {
                // Active: a solid pill so it clearly reads as the tappable action.
                // White on SaveBg keeps contrast in both light and dark.
                Text("Save")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color(.saveBg), in: Capsule())
            } else {
                Text("Save")
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.text).opacity(0.35))
            }
        }
        // Dimmed means there's nothing to save — make it genuinely untappable,
        // not just greyed (it was still firing `action` while looking disabled).
        .disabled(saving || disabled || !hasChanges)
        // The dirty state is otherwise conveyed only by color — announce it.
        .accessibilityValue(hasChanges ? "Unsaved changes" : "No changes")
    }
}
