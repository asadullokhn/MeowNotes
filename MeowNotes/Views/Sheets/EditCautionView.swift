// Owner: TBD (claim by editing this line)
//
// Modal editor for things to be careful about with this cat
// (allergies, behavioral flags, things to avoid). Presented from HomeView.

import SwiftUI

struct EditCautionView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Caution")
                    .font(.largeTitle.bold())
                Text("Placeholder — replace with caution flags editor")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Caution")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview { EditCautionView() }
