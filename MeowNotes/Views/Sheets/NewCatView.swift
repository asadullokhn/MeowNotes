// Owner: TBD (claim by editing this line)
//
// Modal sheet to add a new cat to the user's account.
// Presented from HomeView. Replace the placeholder body.

import SwiftUI

struct NewCatView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("New Cat")
                    .font(.largeTitle.bold())
                Text("Placeholder — replace with new-cat form (name, photo, breed)")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("New Cat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview { NewCatView() }
