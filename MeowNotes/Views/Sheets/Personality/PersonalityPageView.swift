//
//  personalityPage.swift
//  MeowNotes
//
//  Created by Orenz on 26/05/26.
//

import SwiftUI

struct PersonalityPageView: View {
    @State var vm: PersonalityViewModel
    var onSaved: () -> Void = {}
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var auth
    private var catName: String { auth.currentCat?.name ?? "your cat" }

    var body: some View {
        NavigationStack{
            VStack{
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        // MARK: Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Describe your cat in a few words.")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .foregroundStyle(Color("TextColor"))
                                .accessibilityAddTraits(.isHeader)
                            Text("Tap the words that fit")
                                .font(.subheadline)
                                .foregroundStyle(Color("TextColor"))
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        
                        // MARK: Add Custom
                        VStack(alignment: .leading, spacing: 12) {
                            SectionLabel("Add your own")

                            TagInputField(
                                placeholder: "Enter personality",
                                text: $vm.newTag,
                                onAdd: vm.addCustomTag
                            )
                        }
                        
                        // MARK: Selected
                        if !vm.selectedTags.isEmpty {
                            VStack(alignment: .leading, spacing: 14) {
                                SectionLabel("Selected")
                                
                                FlowLayout {
                                    ForEach(vm.selectedTags, id: \.self) { tag in
                                        SelectedBubble(text: tag) {
                                            vm.removeTag(tag)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // MARK: Available
                        if !vm.availableTags.isEmpty {
                            VStack(alignment: .leading, spacing: 14) {
                                SectionLabel("Tap to add")
                                
                                FlowLayout {
                                    ForEach(vm.availableTags, id: \.self) { tag in
                                        AddBubble(text: tag) {
                                            vm.addTag(tag)
                                        }
                                    }
                                    
                                    ForEach(vm.customAvailableTags, id: \.self) { tag in
                                        CustomAddBubble(
                                            text: tag,
                                            onAdd: {
                                                vm.addCustomAvailableTag(tag)
                                            },
                                            onDelete: {
                                                vm.deleteCustomTag(tag)
                                            }
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(Color("AppBg"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color(.text))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        PersonalityPageView2(vm: vm, onSaved: onSaved)
                    } label: {
                        Text("Next").fontWeight(.semibold)
                    }
                    .foregroundStyle(Color(.text))
                    .opacity(vm.selectedTags.isEmpty ? 0.35 : 1)
                    .disabled(vm.selectedTags.isEmpty)
                }
            }
        }
    }
}

//#Preview {
//    NavigationStack {
//        PersonalityPageView()
//    }
//}

