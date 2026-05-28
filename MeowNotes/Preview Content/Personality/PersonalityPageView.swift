//
//  personalityPage.swift
//  MeowNotes
//
//  Created by Orenz on 26/05/26.
//

import SwiftUI

struct PersonalityPageView: View {
    @State private var vm = PersonalityViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack{
            VStack{
                // MARK: Custom Header
                HStack {
                    Text("CAT • PERSONALITY")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                    Button() {
                        dismiss()
                    } label:{
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color("TextColor"))
                            .padding(15)
                            .background(Color("BubbleBorder"))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        // MARK: Description
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Describe CAT in a few words.")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color("TextColor"))
                            
                            Text("Tap the words that fit")
                                .font(.system(size: 14))
                                .foregroundColor(Color("TextColor"))
                        }
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
                                .padding(.horizontal, 14)
                                .frame(height: 48)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color("BubbleBorder"), lineWidth: 1)
                                )
                                
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
                Divider()
                
                // MARK: Bottom Buttons
                HStack(spacing: 16) {
                    Button {
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
                    } label: {
                        Text("Continue")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color("SaveBg"))
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                    }
                }
                .padding()
            }
            .background(Color("AppBg"))
        }
    }
}

#Preview {
    NavigationStack {
        PersonalityPageView()
    }
}

