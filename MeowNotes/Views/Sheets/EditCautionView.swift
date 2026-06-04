// Owner: TBD (claim by editing this line)
//
// Modal editor for things to be careful about with this cat
// (allergies, behavioral flags, things to avoid). Presented from HomeView.

import SwiftUI

struct EditCautionView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var auth

    @State private var vm = CautionModel()
    @State private var saving = false
    @State private var saveError: String?
    @State private var loaded = false

    private var saveErrorBinding: Binding<Bool> {
        Binding(get: { saveError != nil }, set: { if !$0 { saveError = nil } })
    }

    private var catName: String { auth.currentCat?.name ?? "your cat" }

    private var hasChanges: Bool {
        let initial = (auth.currentCat?.notes ?? []).filter { $0.urgent == true }.map { $0.text }
        return vm.selectedTags.map(\.text) != initial
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    // MARK: Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Anything to watch out for?")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundStyle(Color("TextColor"))
                            .accessibilityAddTraits(.isHeader)
                        Text("The must-reads — foods your cat can't eat, warnings, medication. Sitters see these pinned to the top of the guide.")
                            .font(.subheadline)
                            .foregroundStyle(Color("TextColor"))
                    }

                    // MARK: Add custom
                    TagInputField(
                        placeholder: "Add a caution — e.g. 'Bolts for the door'",
                        text: $vm.newTag,
                        onAdd: vm.addCustomTag
                    )

                    // MARK: Added cautions
                    if !vm.selectedTags.isEmpty {
                        VStack(spacing: 8) {
                            ForEach($vm.selectedTags) { $tag in
                                EditableListRow(
                                    text: $tag.text,
                                    accessory: .warning,
                                    onRemove: { vm.removeTag(tag) }
                                )
                            }
                        }
                    }

                    // MARK: Common ones
                    VStack(alignment: .leading, spacing: 14) {
                        SectionLabel("Common ones")
                        ForEach(vm.availableTags, id: \.self) { tag in
                            AddBubble(text: tag, isSelected: vm.selectedTags.contains { $0.text == tag }) {
                                vm.addTag(tag)
                            }
                        }
                        ForEach(vm.customAvailableTags, id: \.self) { tag in
                            CustomAddBubble(
                                text: tag,
                                onAdd: { vm.addCustomAvailableTag(tag) },
                                onDelete: { vm.deleteCustomTag(tag) }
                            )
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color("AppBg"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color(.text))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    SaveToolbarButton(saving: saving, hasChanges: hasChanges, action: save)
                }
            }
            .onAppear(perform: loadCautions)
            .alert("Couldn't save", isPresented: saveErrorBinding) {
                Button("OK", role: .cancel) {}
            } message: { Text(saveError ?? "") }
        }
    }

    private func loadCautions() {
        guard !loaded else { return }
        loaded = true
        vm.selectedTags = (auth.currentCat?.notes ?? [])
            .filter { $0.urgent == true }
            .map { TagItem(text: $0.text) }
    }

    private func save() {
        guard hasChanges else { dismiss(); return }   // nothing changed — no network, no spinner
        guard !saving, let catID = auth.currentCat?.id else { return }
        saving = true
        saveError = nil
        // Keep the non-urgent (Additions) notes; replace only the urgent half.
        let others = (auth.currentCat?.notes ?? []).filter { $0.urgent != true }
        let urgent = vm.selectedTags
            .map { $0.text.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .map { Note(text: $0, urgent: true) }
        let combined = others + urgent
        Task {
            do {
                try await auth.updateNotes(catID: catID, combined)
                dismiss()
            } catch {
                saveError = error.localizedDescription
            }
            saving = false
        }
    }
}

#Preview {
    EditCautionView()
        .environment(AuthManager())
}
