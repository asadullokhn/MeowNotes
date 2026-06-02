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
    @FocusState private var isFocused: Bool

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
                                    HStack(spacing: 12) {
                                        TextField(
                                            "e.g 'Will run if you let the window open'",
                                            text: $vm.newTag
                                        )
                                        .focused($isFocused)
                                        .padding(.horizontal, 14)
                                        .frame(height: 48)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(Color("AddBg"))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color("BubbleSelectedBg"), lineWidth: 1)
                                                .opacity(isFocused ? 1 : 0)
                                        )
                                        .animation(.easeInOut, value: isFocused)
                                        
                                        Button {
                                            vm.addCustomTag()
                                        } label: {
                                            Text("Add")
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 18)
                                                .frame(height: 48)
                                                .background(
                                                    vm.newTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                                    ? Color.gray
                                                    : Color("SaveBg")
                                                )
                                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                        }
                                        .disabled(vm.newTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                    }
                                    .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                }
                                
                                //MARK: INFOS
                                if !vm.selectedTags.isEmpty {
                                    Section(header: Text("INFOS")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color("TextColor"))
                                    ) {
                                        ForEach(vm.selectedTags, id: \.self) { tag in
                                            SelectedBubbleEdit(
                                                text: tag,
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
                                        Text("NEED A NUDGE?")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color("TextColor"))
                                        
                                        ForEach(vm.availableTags, id: \.self) { tag in
                                            let isSelected = vm.selectedTags.contains(tag)
                                            
                                            Button {
                                                if !isSelected {
                                                    vm.addTag(tag)
                                                }
                                            } label: {
                                                Text(tag)
                                                    .padding(.horizontal, 14)
                                                    .padding(.vertical, 8)
                                                    .background(isSelected ? Color.gray.opacity(0.4) : Color("BubbleBg"))
                                                    .foregroundColor(isSelected ? Color.gray.opacity(0.8) : Color("TextColor"))
                                                    .clipShape(Capsule())
                                            }
                                            .buttonStyle(.plain)
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
                            
                            // MARK: Bottom Buttons
                            Section{
                                HStack(spacing: 16) {
                                    Button {
                                        dismiss()
                                    } label: {
                                        Text("Cancel")
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                            .frame(maxWidth: 100)
                                            .frame(height: 54)
                                            .background(Color(.systemGray5))
                                            .clipShape(RoundedRectangle(cornerRadius: 30))
                                    }
                                    
                                    Button {
                                        save()
                                    } label: {
                                        Group {
                                            if saving { ProgressView().tint(.white) }
                                            else { Text("Save").fontWeight(.semibold) }
                                        }
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 54)
                                            .background(Color("SaveBg"))
                                            .clipShape(RoundedRectangle(cornerRadius: 30))
                                    }
                                    .disabled(saving)
                                }
                            }
                            .padding()
                            
                            //MARK: HEADER
                            .toolbar {
                                ToolbarItem(placement: .topBarLeading) {
                                    Text(catName.uppercased() + " • ADDITIONAL INFO")
                                        .fixedSize()
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Color(.text))
                                }
                                .sharedBackgroundVisibility(.hidden)
                                
                                ToolbarItem(placement: .topBarTrailing) {
                                    Button {
                                        dismiss()
                                    } label: {
                                        Image(systemName: "xmark")
                                            .resizable()
                                            .frame(width: 12, height: 12)
                                    }
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
