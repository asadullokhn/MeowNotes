import SwiftUI

struct EditBasicCareView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var auth

    private var catName: String { auth.currentCat?.name ?? "your cat" }

    @State private var checklistItems: [String] = [
        "Fresh water",
        "Food served",
        "Litter box cleaned",
        "Playtime",
        "Brushed"
    ]
    @State private var newChecklistItem = ""
    @State private var saving = false
    @State private var saveError: String?
    @State private var loaded = false
    @FocusState private var focusedCheck: Int?

    private var saveErrorBinding: Binding<Bool> {
        Binding(get: { saveError != nil }, set: { if !$0 { saveError = nil } })
    }

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
                            .foregroundStyle(Color("TextColor"))
                        Text("Cat-care tasks with no fixed time. Your sitter ticks these off in their guide — you just list them here.")
                            .font(.subheadline)
                            .foregroundStyle(Color("TextColor"))
                    }

                    // MARK: Checklist + add custom
                    VStack(spacing: 12) {
                        ForEach(checklistItems.indices, id: \.self) { index in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color(.bubbleSelectedBg))
                                    .frame(width: 6, height: 6)
                                TextField("Check", text: binding(for: index))
                                    .textInputAutocapitalization(.sentences)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(Color(.text))
                                    .focused($focusedCheck, equals: index)
                                Spacer(minLength: 8)
                                Button { focusedCheck = index } label: {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(Color(.text).opacity(0.45))
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Edit check")
                                RemoveCircleButton(size: 32) {
                                    removeChecklistItem(at: index)
                                }
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 14)
                            .background(Color(.bubbleBg), in: RoundedRectangle(cornerRadius: 18))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(focusedCheck == index ? Color(.bubbleSelectedBg) : Color(.bubbleBorder), lineWidth: 1)
                            )
                            .animation(.easeInOut(duration: 0.15), value: focusedCheck)
                        }

                        TagInputField(
                            placeholder: "Add your own - e.g. 'curtains open'",
                            text: $newChecklistItem,
                            onAdd: addChecklistItem
                        )
                    }

                    // MARK: Common ones
                    VStack(alignment: .leading, spacing: 14) {
                        SectionLabel("Common ones")
                        FlowLayout(spacing: 12) {
                            ForEach(commonChecklistItems, id: \.self) { item in
                                AddBubble(text: item, isSelected: isCommonItemAdded(item)) {
                                    addCommonChecklistItem(item)
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
                    Button(action: save) {
                        if saving { ProgressView() }
                        else { Text("Save").fontWeight(.semibold) }
                    }
                    .foregroundStyle(Color(.text))
                    .disabled(saving)
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
            checklistItems = items.map { $0.label }
        }
    }

    private func save() {
        guard !saving, let catID = auth.currentCat?.id else { return }
        saving = true
        saveError = nil
        let items = checklistItems
            .map { $0.trimmingCharacters(in: .whitespaces) }
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

    private func binding(for index: Int) -> Binding<String> {
        Binding(
            get: { checklistItems[index] },
            set: { checklistItems[index] = $0 }
        )
    }

    private func addChecklistItem() {
        let trimmed = newChecklistItem.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        checklistItems.append(trimmed)
        newChecklistItem = ""
    }

    private func removeChecklistItem(at index: Int) {
        checklistItems.remove(at: index)
    }

    private func addCommonChecklistItem(_ item: String) {
        let trimmed = item.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        checklistItems.append(trimmed)
    }

    private func isCommonItemAdded(_ item: String) -> Bool {
        let trimmed = item.trimmingCharacters(in: .whitespacesAndNewlines)
        return checklistItems.contains { $0.trimmingCharacters(in: .whitespacesAndNewlines) == trimmed }
    }
}

#Preview {
    EditBasicCareView()
        .environment(AuthManager())
}
