import SwiftUI

struct EditBasicCareView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var auth

    private var catName: String { auth.currentCat?.name ?? "your cat" }

    @State private var checklistItems: [TagItem] = [
        TagItem(text: "Fresh water"),
        TagItem(text: "Food served"),
        TagItem(text: "Litter box cleaned"),
        TagItem(text: "Playtime"),
        TagItem(text: "Brushed")
    ]
    @State private var newChecklistItem = ""
    @State private var saving = false
    @State private var saveError: String?
    @State private var loaded = false
    @State private var initialChecklist: [String] = []

    private var saveErrorBinding: Binding<Bool> {
        Binding(get: { saveError != nil }, set: { if !$0 { saveError = nil } })
    }

    private var hasChanges: Bool { checklistItems.map(\.text) != initialChecklist }

    private let commonChecklistItems = [
        "Fresh water",
        "Food served",
        "Litter box cleaned",
        "Playtime",
        "Brushed",
        "Scoop litter",
        "Clean bowls",
        "Give meds"
    ]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    // MARK: Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What needs a quick check?")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundStyle(Color("TitleColor"))
                            .accessibilityAddTraits(.isHeader)
                        Text("Cat-care tasks with no fixed time. Your sitter ticks these off in their guide — you just list them here.")
                            .font(.subheadline)
                            .foregroundStyle(Color("TextColor"))
                    }

                    // MARK: Add custom (top) + checklist
                    VStack(spacing: 12) {
                        TagInputField(
                            placeholder: "Add your own - e.g. 'curtains open'",
                            text: $newChecklistItem,
                            onAdd: addChecklistItem
                        )

                        if !checklistItems.isEmpty {
                            VStack(spacing: 8) {
                                ForEach($checklistItems) { $item in
                                    EditableListRow(
                                        text: $item.text,
                                        accessory: .dot,
                                        onRemove: { removeChecklistItem(item) }
                                    )
                                }
                            }
                        }
                    }

                    // MARK: Common ones — hidden once everything's been added
                    let commonChecks = commonChecklistItems.filter { !isCommonItemAdded($0) }
                    if !commonChecks.isEmpty {
                        VStack(alignment: .leading, spacing: 14) {
                            SectionLabel("TAP TO ADD")
                            FlowLayout(spacing: 12) {
                                ForEach(commonChecks, id: \.self) { item in
                                    AddBubble(text: item) {
                                        addCommonChecklistItem(item)
                                    }
                                }
                            }
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
            .onAppear(perform: loadChecks)
            .alert("Couldn't save", isPresented: saveErrorBinding) {
                Button("OK", role: .cancel) {}
            } message: { Text(saveError ?? "") }
        }
    }

    private func loadChecks() {
        guard !loaded else { return }
        loaded = true
        if let items = auth.currentCat?.checks {
            checklistItems = items.map { TagItem(text: $0.label) }
        }
        initialChecklist = checklistItems.map(\.text)
    }

    private func save() {
        guard hasChanges else { dismiss(); return }   // nothing changed — no network, no spinner
        guard !saving, let catID = auth.currentCat?.id else { return }
        saving = true
        saveError = nil
        let items = checklistItems
            .map { $0.text.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .map { CheckItem(label: $0) }
        Task {
            do {
                try await auth.updateChecks(catID: catID, items)
                dismiss()
            } catch {
                saveError = error.localizedDescription
            }
            saving = false
        }
    }

    private func addChecklistItem() {
        let trimmed = newChecklistItem.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        checklistItems.insert(TagItem(text: trimmed), at: 0)   // newest sits right under the input
        newChecklistItem = ""
    }

    private func removeChecklistItem(_ item: TagItem) {
        checklistItems.removeAll { $0.id == item.id }
    }

    private func addCommonChecklistItem(_ item: String) {
        let trimmed = item.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        checklistItems.append(TagItem(text: trimmed))
    }

    private func isCommonItemAdded(_ item: String) -> Bool {
        let trimmed = item.trimmingCharacters(in: .whitespacesAndNewlines)
        return checklistItems.contains { $0.text.trimmingCharacters(in: .whitespacesAndNewlines) == trimmed }
    }
}

#Preview {
    EditBasicCareView()
        .environment(AuthManager())
}
