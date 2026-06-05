// Owner: TBD (claim by editing this line)
//
// Public sitter guide — the read-only view a cat owner shares with a sitter.
// Replace placeholder with the formatted guide UI (cat info, routine, etc.).

import SwiftUI

struct GuideView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Guide")
                .font(.largeTitle.bold())
            Text("Placeholder — sitter-facing summary of the cat")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .navigationTitle("Sitter Guide")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { GuideView() }
}
