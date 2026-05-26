// Owner: TBD (claim by editing this line)
//
// Login screen. Replace the placeholder body with real auth UI.
// Call `onSignIn()` when the user successfully signs in — that's all.
// Do NOT change the signature; ContentView depends on it.

import SwiftUI

struct LoginView: View {
    var onSignIn: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("Login")
                .font(.largeTitle.bold())
            Text("Placeholder — replace with real sign-in UI")
                .foregroundStyle(.secondary)
            Button("Sign in", action: onSignIn)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    LoginView(onSignIn: {})
}
