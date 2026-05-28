//
//  AdditionalPageViewOld.swift
//  MeowNotes
//
//  Created by Orenz on 28/05/26.
//

import SwiftUI

struct AdditionalPageViewOld: View {
    @State private var vm = AdditionalViewModel()
    @Environment(\.dismiss) private var dismiss
    
    private let commonOnesBackground = Color(red: 243.0 / 255.0, green: 236.0 / 255.0, blue: 226.0 / 255.0)
    
    var body: some View {
        NavigationStack {
            VStack{
                // MARK: Custom Header
                HStack {
                    Text("CAT • ADDITIONAL INFO")
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
                            Text("What should sitters know?")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color("TextColor"))
                            
                            Text("Quirks, habits, little tips - Anything else worth knowing. Must-read warning go under Caution.")
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
                                    "e.g 'Will run if you let the window open'",
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
                                Text("INFOS")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("TextColor"))
                                
                                ForEach(vm.selectedTags, id: \.self) { tag in
                                    SelectedBubbleEdit(
                                        text: tag,
                                        onRemove: {
                                            vm.removeTag(tag)
                                        },
                                        onSave: { newValue in
                                            vm.updateTag(old: tag, new: newValue)
                                        }
                                    )
                                }
                            }
                        }
                        
                        // MARK: Available
                        Section {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("NEED A NUDGE?")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("TextColor"))
                                
                                ForEach(vm.availableTags, id: \.self) { tag in
                                    DisableAddBubble(
                                        text: tag,
                                        onAdd: {
                                            vm.addTag(tag)
                                        },
                                        disabled: vm.selectedTags.contains(tag)
                                    )
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
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(commonOnesBackground)
                            )
                            .padding(.vertical, 5)
                        }
                        
                    }
                    .padding()
                }
                Divider()
                
                // MARK: Bottom Buttons
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
                    } label: {
                        Text("Save")
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
            
            //to show sheet handle
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    NavigationStack {
        AdditionalPageViewOld()
    }
}

