// Owner: TBD (claim by editing this line)
//
// Modal editor for the cat's Preferences (likes/dislikes, favorite spots).
// Presented from HomeView. Replace the placeholder body.

import SwiftUI

struct EditPreferencesView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Preferences")
                    .font(.largeTitle.bold())
                Text("Placeholder — replace with preferences editor")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Preferences")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview { EditPreferencesView() }
