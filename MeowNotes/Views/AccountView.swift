// Owner: TBD (claim by editing this line)
//
// Account / profile / settings screen. Replace the placeholder body with
// real account UI. Pushed from HomeView via NavigationLink, so navigation
// back works automatically.

import SwiftUI

struct AccountView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Account")
                .font(.largeTitle.bold())
            Text("Placeholder — profile, settings, sign-out options go here")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { AccountView() }
}
