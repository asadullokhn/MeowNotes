// Owner: TBD (claim by editing this line)
//
// Modal sheet to share the cat's sitter guide link.
// Presented from HomeView. Replace the placeholder body with a real
// share UI (link copy, ShareLink, QR code, etc.).

import SwiftUI

struct ShareView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Share")
                    .font(.largeTitle.bold())
                Text("Placeholder — replace with sitter-link sharing UI")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Share")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview { ShareView() }
