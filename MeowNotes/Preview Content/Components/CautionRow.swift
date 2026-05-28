//
//  CautionRow.swift
//  MeowNotes
//
//  Created by Yimei Winata on 28/05/26.
//

import SwiftUI

struct CautionRow: View {
    
    let caution: CautionModel
    
    @Binding var cautions: [CautionModel]
    @Binding var editingCautionID: UUID?
    var focusedCautionID: FocusState<UUID?>.Binding
    @Binding var savedCommonCautions: [CautionModel]
    
    func bindingForCaution() -> Binding<String> {
        Binding(
            get: {
                caution.text
            },
            set: { newValue in
                
                guard let index = cautions.firstIndex(where: {
                    $0.text == caution.text
                }) else {
                    return
                }
                
                cautions[index].text = newValue
            }
        )
    }
    
    var body: some View {
        
        HStack(spacing: 12) {
            
            // Warning Icon
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.8))
                    .frame(width: 32, height: 32)
                
                Image(systemName: "exclamationmark")
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .bold))
            }
            
            // Text / TextField
            Group {
                
                if editingCautionID == caution.id {
                    
                    TextField(
                        "Edit caution",
                        text: bindingForCaution()
                    )
                    .textFieldStyle(.plain)
                    .font(.body)
                    .fontWeight(.medium)
                    .submitLabel(.done)
                    .focused(focusedCautionID, equals: caution.id)
                    .onSubmit {
                        editingCautionID = nil
                        focusedCautionID.wrappedValue = nil
                    }
                    
                } else {
                    
                    Text(caution.text)
                        .font(.body)
                        .fontWeight(.medium)
                }
            }
            
            Spacer()
            
            // Edit / Save Button
            if editingCautionID == caution.id {
                
                Button {
                    editingCautionID = nil
                    focusedCautionID.wrappedValue = nil
                    
                } label: {
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                }
                
            } else {
                
                Button {
                    editingCautionID = caution.id
                    focusedCautionID.wrappedValue = caution.id
                    
                } label: {
                    Image(systemName: "pencil")
                        .foregroundColor(.pink.opacity(0.7))
                }
            }
            
            // Delete Button
            Button {
                if editingCautionID == caution.id {
                    editingCautionID = nil
                    focusedCautionID.wrappedValue = nil
                }
                
                let cautionText = caution.text
                
                let isPredefined = CautionModel.predefined.contains(where: { $0.text == cautionText })
                
                if !isPredefined && !savedCommonCautions.contains(where: { $0.text == cautionText }) {
                    savedCommonCautions.append(caution)
                }
                
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    cautions.removeAll { item in
                        item.id == caution.id
                    }
                }
            } label: {
                
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                    }
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            Color.red.opacity(0.2),
                            lineWidth: 2
                        )
                )
        )
        .contentShape(RoundedRectangle(cornerRadius: 24))
        .simultaneousGesture(
            TapGesture()
                .onEnded {
                    
                    if editingCautionID != caution.id {
                        editingCautionID = caution.id
                        focusedCautionID.wrappedValue = caution.id
                    }
                }
        )
    }
}
