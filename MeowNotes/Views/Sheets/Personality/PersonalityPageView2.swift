//
//  PersonalityPageView2.swift
//  MeowNotes
//
//  Created by Orenz on 28/05/26.
//

import SwiftUI

struct PersonalityPageView2: View {
    @State var vm = PersonalityViewModel()
    var onSaved: () -> Void = {}
    @State private var saving = false
    @State private var generating = false
    @State private var saveError: String?
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var auth
    private var catName: String { auth.currentCat?.name ?? "your cat" }

    private var hasChanges: Bool {
        let cat = auth.currentCat
        let savedSummary = (cat?.personalitySummary ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let currentSummary = vm.notes.trimmingCharacters(in: .whitespacesAndNewlines)
        if currentSummary != savedSummary { return true }
        return vm.selectedTags != (cat?.personality ?? [])
    }

    private var saveErrorBinding: Binding<Bool> {
        Binding(get: { saveError != nil }, set: { if !$0 { saveError = nil } })
    }
    
    var body: some View {
        NavigationStack{
            VStack{
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        // MARK: Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes for the sitter")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .foregroundStyle(Color("TextColor"))
                            Text("Written from the traits you picked. Tweak the wording, or generate a fresh take.")
                                .font(.subheadline)
                                .foregroundStyle(Color("TextColor"))
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        
                        // MARK: Notes Area
                        VStack(alignment: .leading, spacing: 12) {
                            TextEditor(text: $vm.notes)
                                .characterLimit(500, $vm.notes)
                                .padding(8)
                                .frame(height: 200)
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                )
                                .overlay(alignment: .center) {
                                    if generating {
                                        ProgressView("Writing \(catName)’s note…")
                                            .padding(12)
                                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                        }

                        // MARK: Generate Again Button
                           Button {
                               regenerate()
                           } label: {
                               HStack(spacing: 8) {
                                   Image(systemName: "arrow.clockwise")
                                       .font(.system(size: 14, weight: .semibold))

                                   Text(generating ? "Writing…" : "Generate again")
                                       .fontWeight(.semibold)
                               }
                               .foregroundColor(.white)
                               .padding(.vertical, 12)
                               .frame(maxWidth: .infinity)
                               .background(Color("SaveBg"))
                               .clipShape(RoundedRectangle(cornerRadius: 12))
                               .opacity(generating ? 0.6 : 1)
                           }
                           .disabled(generating)
                    }
                    .padding()
                }
            }
            .background(Color("AppBg"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Back") { dismiss() }
                        .foregroundStyle(Color(.text))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    SaveToolbarButton(saving: saving, hasChanges: hasChanges, disabled: generating, action: save)
                }
            }
            .alert("Couldn't save", isPresented: saveErrorBinding) {
                Button("OK", role: .cancel) {}
            } message: { Text(saveError ?? "") }
            // Land on a freshly written note. Only when there's nothing yet, so an
            // edited or previously-saved summary is never clobbered on re-entry.
            .task {
                if vm.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    vm.genCount = 0
                    await fillSummary()
                }
            }
        }
    }

    private func save() {
        guard !saving, let catID = auth.currentCat?.id else { return }
        saving = true
        saveError = nil
        let traits = vm.selectedTags
        let summary = vm.notes.trimmingCharacters(in: .whitespacesAndNewlines)
        Task {
            do {
                try await auth.updatePersonality(catID: catID, traits: traits, summary: summary)
                onSaved()
            } catch {
                saveError = error.localizedDescription
            }
            saving = false
        }
    }

    // Generate a fresh note: try the server, and on any failure (timeout, 4xx/5xx,
    // offline) fall back to the on-device template so the button never dead-ends.
    // The result is plain, editable text dropped straight into the field.
    private func fillSummary() async {
        guard !generating else { return }
        generating = true
        let name = auth.currentCat?.name ?? "Your cat"
        let traits = vm.selectedTags
        let text: String
        do {
            let generated = try await auth.generatePersonality(name: name, traits: traits)
            let trimmed = generated.trimmingCharacters(in: .whitespacesAndNewlines)
            text = trimmed.isEmpty ? vm.localSummary(name: name) : trimmed
        } catch {
            text = vm.localSummary(name: name)
        }
        vm.notes = text
        generating = false
    }

    // "Generate again" — bump the counter (so the local fallback rephrases) and
    // hit the server once more (temperature 0.85, no seed → a different note).
    private func regenerate() {
        guard !generating else { return }
        vm.genCount += 1
        Task { await fillSummary() }
    }
}

#Preview {
    NavigationStack {
        PersonalityPageView2()
            .environment(AuthManager())
    }
}

