// Owner: TBD (claim by editing this line)
//
// Modal editor for the cat's Medical info (vet, vaccines, conditions).
// Presented from HomeView. Replace the placeholder body.

import SwiftUI

struct EditMedicalView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Medical")
                    .font(.largeTitle.bold())
                Text("Placeholder — replace with vet + medical history editor")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Medical")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview { EditMedicalView() }
