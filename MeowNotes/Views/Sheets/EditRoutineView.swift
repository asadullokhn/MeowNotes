// Owner: TBD (claim by editing this line)
//
// Modal editor for the cat's daily Routine (feeding times, etc.).
// Presented from HomeView. Replace the placeholder body.

import SwiftUI

struct EditRoutineView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Routine")
                    .font(.largeTitle.bold())
                Text("Placeholder — replace with routine editor")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview { EditRoutineView() }
