import SwiftUI

struct ContentView: View {
    @State private var auth = AuthManager()

    var body: some View {
        Group {
            switch auth.phase {
            case .booting:
                SessionBootView()
            case .authenticated:
                HomeView(onSignOut: { auth.logout() })
            case .unauthenticated:
                LoginView(onSignIn: {})
            }
        }
        .environment(auth)
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
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color("AppBg"))
                    .frame(width: 56, height: 56)
                    .background(Color("SaveBg"))
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
