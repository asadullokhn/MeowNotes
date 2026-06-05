import SwiftUI

// VoiceOver announcements for actions that change state in place without moving
// focus — copying the share link, rotating it. A sighted user sees the button
// flip to "Copied!"; this is the screen-reader equivalent.
enum VoiceOver {
    @MainActor
    static func announce(_ message: String) {
        UIAccessibility.post(notification: .announcement, argument: message)
    }
}
