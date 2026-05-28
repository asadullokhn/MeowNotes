import SwiftUI

struct EditBasicCareView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var checklistItems: [String] = [
        "Fresh water",
        "Food served",
        "Litter box cleaned",
        "Playtime",
        "Brushed"
    ]
    @State private var newChecklistItem = ""

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
    private let textColor = Color(red: 61.0 / 255.0, green: 51.0 / 255.0, blue: 41.0 / 255.0)
    private let commonOnesBackground = Color(red: 243.0 / 255.0, green: 236.0 / 255.0, blue: 226.0 / 255.0)

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBg").ignoresSafeArea()
                
                Form {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What needs a quick check?")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundStyle(textColor)
                        Text("Cat-care tasks with no fixed time. Your sitter ticks these off in their guide — you just list them here.")
                            .font(.subheadline)
                            .foregroundStyle(textColor)
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)

                    Section {
                        ForEach(checklistItems.indices, id: \.self) { index in
                            HStack(spacing: 12) {
                                TextField("Check", text: binding(for: index))
                                    .textInputAutocapitalization(.sentences)
                                    .foregroundStyle(textColor)
                                Spacer(minLength: 8)
                                Image(systemName: "pencil")
                                    .foregroundStyle(.secondary)
                                    .accessibilityHidden(true)
                                    .opacity(0.5)
                                Button {
                                    removeChecklistItem(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Remove check")
                            }
                        }

                        HStack {
                            TextField("Add your own - e.g. 'curtains open'", text: $newChecklistItem)
                                .textInputAutocapitalization(.sentences)
                                .foregroundStyle(textColor)
                            Button("Add") { addChecklistItem() }
                                .disabled(newChecklistItem.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                .foregroundStyle(textColor)
                        }
                    }
                    .listRowBackground(Color("BubbleBg"))

                    Section {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("COMMON ONES")
                                .font(.headline)
                                .bold()
                                .foregroundStyle(textColor)
                            
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
                    .listRowBackground(commonOnesBackground)
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Basic Care")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { dismiss() }
                    }
                }
            }
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
                .foregroundStyle(textColor)
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

#Preview { EditBasicCareView() }
