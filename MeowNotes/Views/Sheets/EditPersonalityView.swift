// Owner: TBD (claim by editing this line)
//
// Modal editor for the cat's Personality section. Presented from HomeView.
// Replace the placeholder body — the NavigationStack + "Done" wiring is
// already in place, just build out your form fields.

import SwiftUI

struct EditPersonalityView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Personality")
                    .font(.largeTitle.bold())
                Text("Placeholder — replace with personality editor")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Personality")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview { EditPersonalityView() }
