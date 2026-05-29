//
//  EditCatProfileView.swift
//  MeowNotes
//
//  Created by Gian Denggan Benjamin on 28/05/26.
//
import SwiftUI

struct EditCatProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var catName: String = ""
    @State private var photoLink: String = "https://placecats.com/neo/600/600"
    @State private var age: String = "3"
    let breed = [
        "Domestic Shorthair", "British Shorthair", "Maine Coon",
        "Persian", "Siamese", "Bengal",
        "Ragdoll", "Scottish Fold", "Mixed"
    ]
    @State private var selectedBreed: String = "British Shorthair"
    
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("A little more about them")
                    .font(.title.bold())
                Text("Name")
                    .foregroundStyle(Color(.brown))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .font(Font.body.bold())
                TextField(
                    "Add a caution — e.g. 'Bolts for the door'",
                    text: $catName
                )
                .padding()
                .background(Color(.bubbleBg))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color(.bubbleBorder), lineWidth: 2)
                )
                Text("Photo")
                    .foregroundStyle(Color(.brown))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .font(Font.body.bold())
                HStack {
                    Image("Cat")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                    VStack(spacing: 8) {
                        Button {
                            print("Button tapped")
                        } label: {
                            HStack{
                                Image(systemName: "square.and.arrow.up")
                                Text("Upload from device")
                            }
                            .padding(10)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .foregroundColor(.black)
                            
                        }
                        TextField(
                            "Insert Photo Link",
                            text: $photoLink
                        )
                        .padding()
                        .background(Color(.bubbleBg))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color(.bubbleBorder), lineWidth: 2)
                        )
                    }
                }
                HStack {
                    VStack(spacing :10){
                        Text("Breed")
                            .foregroundStyle(Color(.brown))
                            .foregroundStyle(.secondary)
                            .frame(alignment: .leading)
                            .font(Font.body.bold())
                        TextField(
                            "",
                            text: $selectedBreed
                            
                        )
                        .padding()
                        .background(Color(.bubbleBg))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color(.bubbleBorder), lineWidth: 2)
                        )
                        
                    }
                    Spacer()
                    VStack{
                        Text("Age")
                            .foregroundStyle(Color(.brown))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .font(Font.body.bold())
                        TextField(
                            "Insert Photo Link",
                            text: $age
                        )
                        .padding()
                        .background(Color(.bubbleBg))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color(.bubbleBorder), lineWidth: 2)
                        )
                    }
                }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 12) {
                    
                    // Loop through your list of breeds
                    ForEach(breed, id: \.self) { breed in
                        
                        Button(action: {
                            // 3. The Action: Update the state variable when tapped
                            selectedBreed = breed
                        }) {
                            Text(breed)
                                .font(.system(size: 14, weight: .medium))
                                .padding(.vertical, 10)
                                .padding(.horizontal, 16)
                            // 4. The Styling: Check if THIS chip is the selected one
                                .background(selectedBreed == breed ? Color(red: 0.5, green: 0.6, blue: 0.5) : Color.white)
                                .foregroundColor(selectedBreed == breed ? .white : .black.opacity(0.8))
                                .cornerRadius(25) // Makes the pill shape
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer() // Pushes everything to the top
            }
            .padding(.top)
            // A light gray background so the white chips pop
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
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
        .background(Color(.background))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {

            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Luna . Basics")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { dismiss() } label:{ Image(systemName: "xmark") }
            }
        }
        
        .background(Color(red: 0.96, green: 0.95, blue: 0.93))    }
}

#Preview { EditCatProfileView() }
