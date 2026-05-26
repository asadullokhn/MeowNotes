// Owner: TBD (claim by editing this line)
//
// Modal editor for free-form Notes / Additions about the cat.
// Presented from HomeView. Replace the placeholder body.

import SwiftUI

struct EditNotesView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Notes")
                    .font(.largeTitle.bold())
                Text("Placeholder — replace with free-form notes editor")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview { EditNotesView() }
