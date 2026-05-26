import SwiftUI

struct ContentView: View {
    @State private var isAuthed = false

    var body: some View {
        Text("MeowNotes")
        if isAuthed {
            HomeView(onSignOut: { isAuthed = false })
        } else {
            LoginView(onSignIn: { isAuthed = true })
        }
    }
}

#Preview("Authed") {
    HomeView(onSignOut: {})
}

#Preview("Login") {
    LoginView(onSignIn: {})
}
