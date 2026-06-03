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

    private var saveErrorBinding: Binding<Bool> {
        Binding(get: { saveError != nil }, set: { if !$0 { saveError = nil } })
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: Background
                Color("AppBg")
                    .ignoresSafeArea()
                    .overlay(
                        VStack(spacing: 0) {
                            // MARK: FORM CONTENT
                            Form {
                                //MARK: DESCRIPTION
                                Section {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("What should sitters know?")
                                            .font(.largeTitle)
                                            .fontWeight(.bold)
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(nil)
                                            .fixedSize(horizontal: false, vertical: true)
                                            .foregroundStyle(Color("TextColor"))
                                        Text("Quirks, habits, little tips - Anything else worth knowing. Must-read warning go under Caution.")
                                            .font(.subheadline)
                                            .foregroundStyle(Color("TextColor"))
                                    }
                                    .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                }
                                
                                //MARK: ADD CUSTOM
                                Section {
                                    TagInputField(
                                        placeholder: "e.g 'Will run if you let the window open'",
                                        text: $vm.newTag,
                                        onAdd: vm.addCustomTag
                                    )
                                    .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                }
                                
                                //MARK: INFOS
                                if !vm.selectedTags.isEmpty {
                                    Section(header: SectionLabel("Infos")) {
                                        ForEach(vm.selectedTags, id: \.self) { tag in
                                            EditableListRow(
                                                text: tag,
                                                accessory: .dot,
                                                onRemove: { vm.removeTag(tag) },
                                                onSave: { newValue in
                                                    vm.updateTag(old: tag, new: newValue)
                                                }
                                            )
                                            .listRowBackground(Color.clear)
                                            .listRowSeparator(.hidden)
                                            .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                                        }
                                    }
                                }
                                
                                //MARK: PRE-DEFINE
                                Section {
                                    VStack(alignment: .leading, spacing: 14) {
                                        SectionLabel("Need a nudge?")

                                        ForEach(vm.availableTags, id: \.self) { tag in
                                            AddBubble(
                                                text: tag,
                                                isSelected: vm.selectedTags.contains(tag)
                                            ) { vm.addTag(tag) }
                                        }

                                        ForEach(vm.customAvailableTags, id: \.self) { tag in
                                            CustomAddBubble(
                                                text: tag,
                                                onAdd: { vm.addCustomAvailableTag(tag) },
                                                onDelete: { vm.deleteCustomTag(tag) }
                                            )
                                        }
                                    }
                                    .padding(.vertical, 6)
                                }
                                .listRowBackground(Color("BubbleSectionBg"))
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
                    )
                    .onAppear(perform: loadNotes)
                    .alert("Couldn't save", isPresented: saveErrorBinding) {
                        Button("OK", role: .cancel) {}
                    } message: { Text(saveError ?? "") }
            }
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

#Preview{
    AdditionalPageView()
        .environment(AuthManager())
        .preferredColorScheme(.dark)
}
