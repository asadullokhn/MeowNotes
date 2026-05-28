//
//  PersonalityPageView2.swift
//  MeowNotes
//
//  Created by Orenz on 28/05/26.
//

import SwiftUI

struct PersonalityPageView2: View {
    @State var vm = PersonalityViewModel()
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
                            Text("Notes for the sitter")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color("TextColor"))
                            
                            Text("Written from the traits you picked. Tweak the wording, or generate a fresh take.")
                                .font(.system(size: 14))
                                .foregroundColor(Color("TextColor"))
                        }
                        // MARK: Notes Area
                        VStack(alignment: .leading, spacing: 12) {
                            TextEditor(text: $vm.notes)
                                .padding(8)
                                .frame(height: 200)
                                .background(Color(.white))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                )
                        }
                        
                        // MARK: Generate Again Button
                           Button {
                               vm.generateAgain()
                           } label: {
                               HStack(spacing: 8) {
                                   Image(systemName: "arrow.clockwise")
                                       .font(.system(size: 14, weight: .semibold))

                                   Text("Generate again")
                                       .fontWeight(.semibold)
                               }
                               .foregroundColor(.white)
                               .padding(.vertical, 12)
                               .frame(maxWidth: .infinity)
                               .background(Color("SaveBg"))
                               .clipShape(RoundedRectangle(cornerRadius: 12))
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
                        Text("Back")
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
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    NavigationStack {
        PersonalityPageView2()
    }
}

