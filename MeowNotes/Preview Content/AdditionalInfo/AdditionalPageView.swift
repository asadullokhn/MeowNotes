//
//  AdditionalPageView.swift
//  MeowNotes
//
//  Created by Orenz on 28/05/26.
//

import SwiftUI

struct AdditionalPageView: View {
    @State private var vm = AdditionalViewModel()
    @Environment(\.dismiss) private var dismiss
    
    private let commonOnesBackground = Color(red: 243/255, green: 236/255, blue: 226/255)
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: Background
                Color("AppBg")
                    .ignoresSafeArea()
                    .overlay(
                        VStack(spacing: 0) {
                            // MARK: CUSTOM HEADER (VISIBLE FIXED)
                            HStack {
                                Text("CAT • ADDITIONAL INFO")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                Button {
                                    dismiss()
                                } label: {
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
                            .background(Color("AppBg"))
                            
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
                                .listRowBackground(commonOnesBackground)
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
                            }
                            .padding()
                        }
                    )
            }
        }
    }
}

#Preview{
    AdditionalPageView()
}
