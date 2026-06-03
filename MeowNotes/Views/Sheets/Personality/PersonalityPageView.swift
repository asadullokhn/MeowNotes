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
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack{
            VStack{
                ScrollView {
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
                            Text("Tap the words that fit")
                                .font(.subheadline)
                                .foregroundStyle(Color("TextColor"))
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        
                        // MARK: Add Custom
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ADD YOUR OWN")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(Color("TextColor"))
                            
                            HStack(spacing: 12) {
                                TextField(
                                    "Enter personality",
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
                                
                                Button(action: vm.addCustomTag) {
                                    Text("Add")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 18)
                                        .frame(height: 48)
                                        .background(vm.newTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color("SaveBg"))
                                        .clipShape(RoundedRectangle(cornerRadius: 30))
                                }
                                .disabled(vm.newTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                            
                        }
                        
                        // MARK: Selected
                        if !vm.selectedTags.isEmpty {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("SELECTED")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("TextColor"))
                                
                                WrapView {
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
                                Text("TAP TO ADD")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("TextColor"))
                                
                                WrapView {
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
                    .disabled(vm.selectedTags.isEmpty)
                }
            }
            
            //to show sheet handle
            .presentationDragIndicator(.visible)
        }
    }
}

//#Preview {
//    NavigationStack {
//        PersonalityPageView()
//    }
//}

