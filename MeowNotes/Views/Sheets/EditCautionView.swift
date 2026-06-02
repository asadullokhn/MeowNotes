// Owner: TBD (claim by editing this line)
//
// Modal editor for things to be careful about with this cat
// (allergies, behavioral flags, things to avoid). Presented from HomeView.

import SwiftUI

struct EditCautionView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var auth
    
    @State private var vm = CautionModel()
    
    private var catName: String { auth.currentCat?.name ?? "your cat" }
    
    var body: some View {
        NavigationStack {
            Color("AppBg")
                .ignoresSafeArea()
                .overlay(
                    VStack(spacing: 16) {
                        Form {
                            Section {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Anything to watch out for?")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(nil)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .foregroundStyle(Color("TextColor"))
                                    
                                    Text("The must-reads — foods \(catName.capitalized) can't eat, warnings, medication. Sitters see these pinned to the top of the guide.")
                                        .font(.subheadline)
                                        .foregroundStyle(Color("TextColor"))
                                }
                                .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            }

                            
                            //MARK: Added caution
                            if !vm.selectedTags.isEmpty {
                                
                                ForEach(vm.selectedTags, id: \.self) { tag in
                                    SelectedBubbleCautionEdit(
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
                            
                            //MARK: ADD CUSTOM
                            Section {
                                HStack(spacing: 12) {
                                    TextField(
                                        "Add a caution — e.g. 'Bolts for the door'",
                                        text: $vm.newTag
                                    )
                                    .padding(.horizontal, 14)
                                    .frame(height: 48)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color("AddBg"))
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
                            
                          
                            //MARK: PRE-DEFINE
                            Section {
                                VStack(alignment: .leading, spacing: 14) {
                                    Text("COMMON ONES")
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
                                            Image(systemName: "plus")
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 10, height: 10)
                                            Text(tag)
                                        }
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(isSelected ? Color.gray.opacity(0.4) : Color("BubbleBg"))
                                        .foregroundColor(isSelected ? Color.gray.opacity(0.8) : Color("TextColor"))
                                        .clipShape(Capsule())
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
                            }
                            .listRowBackground(Color("BubbleSectionBg"))
                        }
                        .scrollContentBackground(.hidden)
                        
                        //Divider
                        Rectangle()
                            .fill(Color(.bubbleBorder))
                            .frame(height: 2)
                            .listRowBackground(Color.clear)
                            .listRowInsets(.init())
                            .padding()
                        
                        //Cancel and Save
                        HStack {
                            
                            Button {
                                dismiss()
                            } label: {
                                Text("Cancel")
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.text))
                                    .frame(maxWidth: 100)
                                    .frame(height: 54)
                                    .background(Color(.bubbleBg))
                                    .clipShape(RoundedRectangle(cornerRadius: 30))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(Color(.bubbleBorder), lineWidth: 1)
                                    )
                            }
                            
                            Button {
                                dismiss()
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
                        .listRowBackground(Color.clear)
                        .listRowInsets(.init())
                        .padding()
                        
                    }
                        .padding(1)
                        .background(Color(.background))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            
                            ToolbarItem(placement: .topBarLeading) {
                                Text(catName.uppercased() + " · CAUTION")
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
                )
        }
    }
}

#Preview {
    EditCautionView()
        .environment(AuthManager())
}
