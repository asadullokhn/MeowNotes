import SwiftUI

// App-wide appearance preference, set from the profile screen and persisted in
// UserDefaults. `system` follows the device setting (the default).
enum AppAppearance: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }
    var label: String {
        switch self {
        case .system: return "System"
        case .light:  return "Light"
        case .dark:   return "Dark"
        }
    }
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

struct ContentView: View {
    @State private var auth = AuthManager()
    @AppStorage("appearance") private var appearance = AppAppearance.system.rawValue

    var body: some View {
        Group {
            switch auth.phase {
            case .booting:
                SessionBootView()
            case .authenticated:
                if auth.cats.isEmpty {
                    WelcomeView()
                } else {
                    HomeView(onSignOut: { auth.logout() })
                }
            case .unauthenticated:
                LoginView(onSignIn: {})
            }
        }
        .environment(auth)
        .preferredColorScheme(AppAppearance(rawValue: appearance)?.colorScheme)
        .task { await auth.boot() }
    }
}

// Brief launch screen shown while we check the Keychain for a stored session
// and hydrate from GET /api/me.
struct SessionBootView: View {
    var body: some View {
        ZStack {
            Color("AppBg").ignoresSafeArea()
            VStack(spacing: 16) {
                Image("AppLogo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                ProgressView().tint(Color("TextColor"))
            }
        }
    }
}

#Preview("Login") {
    LoginView(onSignIn: {})
        .environment(AuthManager())
}

#Preview("Authed") {
    HomeView(onSignOut: {})
        .environment(AuthManager())
}
