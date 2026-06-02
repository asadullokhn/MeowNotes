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
            ZStack {
                Color("AppBg").ignoresSafeArea()
                
                Form {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("What needs a quick check?")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color("TextColor"))
                        
                        Text("Cat-care tasks with no fixed time. Your sitter ticks these off in their guide — you just list them here.")
                            .font(.system(size: 14))
                            .foregroundColor(Color("TextColor"))
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)

                    Section {
                        VStack(spacing: 12) {
                            ForEach(checklistItems.indices, id: \.self) { index in
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color(.bubbleSelectedBg))
                                        .frame(width: 6, height: 6)
                                    TextField("Check", text: binding(for: index))
                                        .textInputAutocapitalization(.sentences)
                                        .font(.callout.weight(.semibold))
                                        .foregroundStyle(Color(.text))
                                    Spacer(minLength: 8)
                                    Image(systemName: "pencil")
                                        .foregroundStyle(.secondary)
                                        .accessibilityHidden(true)
                                        .opacity(0.5)
                                    Button {
                                        removeChecklistItem(at: index)
                                    } label: {
                                        ZStack {
                                            Circle()
                                                .fill(Color(.backgroundPredefined))
                                            Image(systemName: "xmark")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundStyle(Color(.xIcon).opacity(0.5))
                                        }
                                        .frame(width: 32, height: 32)
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("Remove check")
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 14)
                                .background(Color(.bubbleBg), in: RoundedRectangle(cornerRadius: 18))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color(.bubbleBorder), lineWidth: 1)
                                )
                            }
                            
                            Spacer()

                            HStack(spacing: 10) {
                                TextField("Add your own - e.g. 'curtains open'", text: $newChecklistItem)
                                    .textInputAutocapitalization(.sentences)
                                    .foregroundStyle(Color(.text))
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 14)
                                    .background(Color(.bubbleBg), in: RoundedRectangle(cornerRadius: 14))

                                Button {
                                    addChecklistItem()
                                } label: {
                                    Text("Add")
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Color.white)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 16)
                                        .background(newChecklistItem != "" ? Color(.addButtonBasicCare) : Color(.addButtonBasicCare).opacity(0.5))
                                        .clipShape(RoundedRectangle(cornerRadius: 120))
                                }
                                .disabled(newChecklistItem.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)

                    Section {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("COMMON ONES")
                                .font(.headline)
                                .bold()
                                .foregroundColor(Color("TextColor"))
                            
                            FlowLayout(spacing: 12) {
                                ForEach(commonChecklistItems, id: \.self) { item in
                                    let isAdded = isCommonItemAdded(item)
                                    Button {
                                        addCommonChecklistItem(item)
                                    } label: {
                                        ViewThatFits(in: .horizontal) {
                                            commonItemLabel(item, expanded: false)
                                            commonItemLabel(item, expanded: true)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    .disabled(isAdded)
                                    .opacity(isAdded ? 0.4 : 1)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listRowBackground(Color(.backgroundPredefined))
                }
                .scrollContentBackground(.hidden)
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

    private func commonItemLabel(_ item: String, expanded: Bool) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "plus")
            Text(item)
                .lineLimit(expanded ? nil : 1)
                .multilineTextAlignment(.leading)
                .foregroundStyle(Color("TextColor"))
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .frame(maxWidth: expanded ? .infinity : nil, alignment: .leading)
        .background(
            Capsule()
                .fill(Color.secondary.opacity(0.15))
        )
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    EditBasicCareView()
        .environment(AuthManager())
}
