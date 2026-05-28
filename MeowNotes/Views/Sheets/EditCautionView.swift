// Owner: TBD (claim by editing this line)
//
// Modal editor for things to be careful about with this cat
// (allergies, behavioral flags, things to avoid). Presented from HomeView.

import SwiftUI


struct EditCautionView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var inputCaution : String = ""
    
    var catName = "gohan"
    
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                //Title
                Text("Anything to watch out for?")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(.saveBg))
                    .padding(.trailing)
                
                //Sub-Title
                Text("The must-reads — foods \(catName.capitalized) can't eat, warnings, medication. Sitters see these pinned to the top of the guide.")
                    .font(.subheadline)
                    .foregroundStyle(Color(.text))
                    .multilineTextAlignment(.leading)
                
                //Form Data User
                Form {
                    //Input Field
                    HStack(spacing: 12) {
                        TextField("Add a caution — e.g. 'Bolts for the door'", text: $inputCaution)
                            .padding()
                            .background(Color(.bubbleBg))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color(.bubbleBorder), lineWidth: 2)
                            )
                            
                        
                        Button {
                            // code
                        } label: {
                            Text("Add")
                                .fontWeight(.semibold)
                                .padding()
                                .background(Color(.addButton))
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
             
                    .listRowBackground(Color.clear)
                    .listRowInsets(.init())
                    
                    //Common Ones
                    
                    VStack {
                        Text("COMMON ONES")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(.text))
                        
                        
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.backgroundPredefined))
                    .listRowBackground(Color.clear)
                    .listRowInsets(.init())
                    
                }
                .listRowSpacing(20)
                .contentMargins(.top, 0)
                .scrollContentBackground(.hidden)
                
            }
            .background(
                Color(.background)
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement:.topBarLeading){
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

#Preview { EditCautionView() }
