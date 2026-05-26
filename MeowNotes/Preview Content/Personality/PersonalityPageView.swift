//
//  personalityPage.swift
//  MeowNotes
//
//  Created by Orenz on 26/05/26.
//

import SwiftUI

struct PersonalityPageView: View {
    @StateObject private var vm = PersonalityViewModel()
    
    var body: some View {
        VStack{
            ScrollView {
                
                VStack(alignment: .leading, spacing: 28) {
                    // MARK: Description
                    VStack(alignment: .leading) {
                        Text("Describe CAT in a few words.")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text("Tap the words that fit")
                            .font(.subheadline)
                    }
                    
                    // MARK: Selected
                    if !vm.selectedTags.isEmpty {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("SELECTED")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                            
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
                    VStack(alignment: .leading, spacing: 14) {
                        Text("TAP TO ADD")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        
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
                    
                    // MARK: Add Custom
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ADD YOUR OWN")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 12) {
                            TextField(
                                "Enter personality",
                                text: $vm.newTag
                            )
                            .padding(.horizontal, 14)
                            .frame(height: 48)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            
                            Button(action: vm.addCustomTag) {
                                Text("Add")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 18)
                                    .frame(height: 48)
                                    .background(Color.blue)
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 30)
                                    )
                            }
                        }
                    }
                    Spacer(minLength: 120)
                }
                .padding()
            }
            
            // MARK: Bottom Buttons
            HStack(spacing: 16) {
                Button {
                } label: {
                    Text("Cancel")
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
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
                        .background(Color("Cream"))
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                }
            }
            .padding()
            .background(.ultraThinMaterial)
        }
        .navigationTitle("Personality")
    }
}

#Preview {
    NavigationStack {
        PersonalityPageView()
    }
}

