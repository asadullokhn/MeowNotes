// Owner: TBD (claim by editing this line)
//
// Bridges APNs into the SwiftUI app: asks permission, registers for remote
// notifications, ships the device token to our backend (POST /api/devices), and
// presents notifications while the app is foregrounded.

import SwiftUI
import UserNotifications

@MainActor
final class PushManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = PushManager()
    private weak var auth: AuthManager?
    private override init() { super.init() }

    // Called once we're authenticated. Asks for permission the first time, then
    // (re)registers so the backend always has a fresh token for the signed-in
    // user. Re-registering on each launch is cheap and keeps the token current.
    func syncRegistration(auth: AuthManager) async {
        self.auth = auth
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        switch await center.notificationSettings().authorizationStatus {
        case .notDetermined:
            let granted = (try? await center.requestAuthorization(options: [.alert, .badge, .sound])) ?? false
            if granted { UIApplication.shared.registerForRemoteNotifications() }
        case .authorized, .provisional, .ephemeral:
            UIApplication.shared.registerForRemoteNotifications()
        default:
            break   // denied — respect the user's choice, don't nag
        }
    }

    // APNs handed us a token (via AppDelegate) — forward it to the backend.
    func handleToken(_ deviceToken: Data) {
        let hex = deviceToken.map { String(format: "%02x", $0) }.joined()
        Task { try? await auth?.registerDevice(token: hex) }
    }

    // Show the banner even when MENG is in the foreground.
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .badge]
    }

    // Tapped a notification — deep-link routing TBD once notification types exist.
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            didReceive response: UNNotificationResponse) async {
    }
}

// SwiftUI has no app delegate, but the remote-notification device token only
// arrives through UIApplicationDelegate — so we adapt a minimal one.
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Task { @MainActor in PushManager.shared.handleToken(deviceToken) }
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // No token this time (e.g. no network / missing entitlement) — the next
        // launch retries via syncRegistration.
    }
}
