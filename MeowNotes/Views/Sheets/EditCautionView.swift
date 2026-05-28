// Owner: TBD (claim by editing this line)
//
// Modal editor for things to be careful about with this cat
// (allergies, behavioral flags, things to avoid). Presented from HomeView.

import SwiftUI

struct EditCautionView: View {
    
    func addCaution() {
        let trimmed = inputCaution.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        
        if !cautions.contains(where: { $0.text == trimmed }) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                cautions.append(CautionModel(text: trimmed))
            }
        }
        
        inputCaution = ""
    }
    
    func bindingForCaution(_ caution: CautionModel) -> Binding<String> {
        Binding(
            get: {
                caution.text
            },
            set: { newValue in
                guard let index = cautions.firstIndex(where: {
                    $0.id == caution.id
                }) else {
                    return
                }
                
                cautions[index].text = newValue
            }
        )
    }
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var inputCaution: String = ""
    @State private var editingCautionID: UUID?
    @State private var cautions: [CautionModel] = []
    @State private var savedCommonCautions: [CautionModel] = []

    
    @FocusState private var focusedCautionID: UUID?
    
    var catName = "gohan"
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                
                // Title
                Text("Anything to watch out for?")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(.saveBg))
                    .padding(.trailing)
                
                // Subtitle
                Text("The must-reads — foods \(catName.capitalized) can't eat, warnings, medication. Sitters see these pinned to the top of the guide.")
                    .font(.subheadline)
                    .foregroundStyle(Color(.text))
                    .multilineTextAlignment(.leading)
                
                ScrollView {
                    
                    if !cautions.isEmpty {
                        VStack(spacing: 12) {
                            
                            ForEach(cautions) { caution in
                                CautionRow(
                                    caution: caution,
                                    cautions: $cautions,
                                    editingCautionID: $editingCautionID,
                                    focusedCautionID: $focusedCautionID,
                                    savedCommonCautions: $savedCommonCautions
                                )
                            }
                        }
                        .animation(.spring(), value: cautions)
                        .listRowBackground(Color.clear)
                        .listRowInsets(.init())
                    }
                    
                    HStack(spacing: 12) {
                        
                        TextField(
                            "Add a caution — e.g. 'Bolts for the door'",
                            text: $inputCaution
                        )
                        .padding()
                        .background(Color(.bubbleBg))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color(.bubbleBorder), lineWidth: 2)
                        )
                        
                        Button {
                            addCaution()
                        } label: {
                            Text("Add")
                                .fontWeight(.semibold)
                                .padding()
                                .background(Color(.addButton))
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                        .disabled(
                            inputCaution
                                .trimmingCharacters(in: .whitespaces)
                                .isEmpty
                        )
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(.init())
                    
                    VStack {
                        
                        Text("COMMON ONES")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(.text))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        WrapView {
                            
                            // Predefined
                            ForEach(
                                CautionModel.predefined,
                                id: \.id
                            ) { tag in
                                
                                AddBubble(
                                    text: tag.text,
                                    onTap: {
                                        print("Tapped: \(tag.text)")
                                                print("Cautions before: \(cautions.map(\.text))")
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                                    if cautions.contains(where: { $0.text == tag.text }) {
                                                        cautions.removeAll { $0.text == tag.text }
                                                    } else {
                                                        cautions.append(CautionModel(text: tag.text))
                                                    }
                                                }
                                                print("Cautions after: \(cautions.map(\.text))")
                                    }
                                )
                            }
                            
                            ForEach(
                                Array(savedCommonCautions.enumerated()),
                                id: \.offset
                            ) { _, tag in
                                
                                CustomAddBubble(
                                    text: tag.text,
                                    onAdd: {
                                        
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            if cautions.contains(where: { $0.text == tag.text }) {
                                                cautions.removeAll { $0.text == tag.text }
                                            } else {
                                                cautions.append(CautionModel(text: tag.text))       
                                            }
                                        }
                                    },
                                    
                                    onDelete: {
                                        
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            savedCommonCautions.removeAll {
                                                $0.text == tag.text
                                            }
                                        }
                                    }
                                )
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        Color(.backgroundPredefined)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    )

                    .listRowBackground(Color.clear)
                    .listRowInsets(.init())
                    
                    
                }
                .padding()
                
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
                            .background(Color(.white))
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                    }
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Save Caution")
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
        }
    }
}

#Preview {
    EditCautionView()
}
