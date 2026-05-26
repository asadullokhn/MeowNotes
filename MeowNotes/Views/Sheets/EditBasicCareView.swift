// Owner: TBD (claim by editing this line)
//
// Modal editor for the cat's Basic Care checklist (litter, water, brushing).
// Presented from HomeView. Replace the placeholder body.

import SwiftUI

struct EditBasicCareView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Basic Care")
                    .font(.largeTitle.bold())
                Text("Placeholder — replace with care checklist editor")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Basic Care")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview { EditBasicCareView() }
