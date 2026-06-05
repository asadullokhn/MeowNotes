import SwiftUI

@main
struct MENGApp: App {
    // Needed so APNs can hand us the device token (SwiftUI has no app delegate).
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
