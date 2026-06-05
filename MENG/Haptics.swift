import UIKit

// Light haptic feedback, gated by the user's "haptics" preference (default on,
// toggled from the Account screen). Call from main-actor UI actions.
@MainActor
enum Haptics {
    static var isEnabled: Bool {
        UserDefaults.standard.object(forKey: "haptics") as? Bool ?? true
    }

    // A tap for buttons, chips, and selections.
    static func tap(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    // A success notification, e.g. after a save.
    static func success() {
        guard isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
