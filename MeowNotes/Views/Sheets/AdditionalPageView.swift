//
//  AdditionalPageView.swift
//  MeowNotes
//
//  Created by Orenz on 28/05/26.
//

import SwiftUI

struct AdditionalPageView: View {
    @State private var vm = AdditionalViewModel()
    @State private var saving = false
    @State private var saveError: String?
    @State private var loaded = false
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var auth
    private var catName: String { auth.currentCat?.name ?? "your cat" }

    private var hasChanges: Bool {
        let initial = (auth.currentCat?.notes ?? []).filter { $0.urgent != true }.map { $0.text }
        return vm.selectedTags != initial
    }

    private var saveErrorBinding: Binding<Bool> {
        Binding(get: { saveError != nil }, set: { if !$0 { saveError = nil } })
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    // MARK: Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What should sitters know?")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundStyle(Color("TextColor"))
                        Text("Quirks, habits, little tips - Anything else worth knowing. Must-read warning go under Caution.")
                            .font(.subheadline)
                            .foregroundStyle(Color("TextColor"))
                    }

                    // MARK: Add custom
                    TagInputField(
                        placeholder: "e.g 'Will run if you let the window open'",
                        text: $vm.newTag,
                        onAdd: vm.addCustomTag
                    )

                    // MARK: Infos
                    if !vm.selectedTags.isEmpty {
                        VStack(alignment: .leading, spacing: 14) {
                            SectionLabel("Infos")
                            VStack(spacing: 8) {
                                ForEach(vm.selectedTags, id: \.self) { tag in
                                    EditableListRow(
                                        text: tag,
                                        accessory: .dot,
                                        onRemove: { vm.removeTag(tag) },
                                        onSave: { newValue in vm.updateTag(old: tag, new: newValue) }
                                    )
                                }
                            }
                        }
                    }

                    // MARK: Need a nudge
                    VStack(alignment: .leading, spacing: 14) {
                        SectionLabel("Need a nudge?")
                        ForEach(vm.availableTags, id: \.self) { tag in
                            AddBubble(text: tag, isSelected: vm.selectedTags.contains(tag)) {
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
            .onAppear(perform: loadNotes)
            .alert("Couldn't save", isPresented: saveErrorBinding) {
                Button("OK", role: .cancel) {}
            } message: { Text(saveError ?? "") }
        }
    }

    private func loadNotes() {
        guard !loaded else { return }
        loaded = true
        vm.selectedTags = (auth.currentCat?.notes ?? [])
            .filter { $0.urgent != true }
            .map { $0.text }
    }

    private func save() {
        guard !saving, let catID = auth.currentCat?.id else { return }
        saving = true
        saveError = nil
        // Keep the urgent (Caution) notes; replace only the non-urgent half.
        let others = (auth.currentCat?.notes ?? []).filter { $0.urgent == true }
        let additions = vm.selectedTags
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .map { Note(text: $0, urgent: false) }
        let combined = others + additions
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
    AdditionalPageView()
        .environment(AuthManager())
        .preferredColorScheme(.dark)
}
