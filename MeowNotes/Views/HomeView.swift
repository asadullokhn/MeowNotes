import SwiftUI

enum HomeSheet: String, Identifiable {
    case newCat, personality, routine, basicCare, preferences, caution, medical, notes, share, editCat, account
    var id: String { rawValue }
}

// 1. Define a 2-column layout with flexible widths and spacing
let columns = [
    GridItem(.flexible(), spacing: 16),
    GridItem(.flexible(), spacing: 16)
]

struct HomeView: View {
    var onSignOut: () -> Void
    @State private var activeSheet: HomeSheet?
    
    var body: some View {
        NavigationStack {
            // Using a ScrollView so the grid can scroll on smaller screens
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Hero Image
                    ZStack(alignment: .bottomLeading) {
                        Image("Cat") // Placeholder
                            .frame(width: 350, height: 200)
                            .background(Color.gray.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                        
                        Button(action: { activeSheet = .editCat }) {
                            HStack{
                                Image(systemName: "pencil")
                                Text("Edit Profile")
                            }
                            .padding(10)
                            .background(Color.white.opacity(0.6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .foregroundColor(.brown)
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 20)
                        .frame(width: 350, height: 200, alignment: .topTrailing)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Mochi")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("British Shorthair, 2")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 20)
                    }
                    
                    // MARK: - Share Banner
                    Button(action: { activeSheet = .share }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .frame(width: 370, height: 75)
                                .foregroundStyle(Color.brown)

                            HStack(spacing: 10) {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.white)
                                Text("Share Mochi's Care Guide")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 40)
                        }
                    }

                    // MARK: - 2-Column Grid
                    LazyVGrid(columns: columns, spacing: 16) {
                        GridCard(icon: "pawprint", title: "Personality", subtitle: "7 traits") { activeSheet = .personality }
                        GridCard(icon: "clock", title: "Routine", subtitle: "5 things a day") { activeSheet = .routine }
                        GridCard(icon: "list.bullet", title: "Basic Care", subtitle: "4 quick checks") { activeSheet = .basicCare }
                        GridCard(icon: "exclamationmark.triangle", title: "Caution", subtitle: "2 things flagged") { activeSheet = .caution }
                        GridCard(icon: "cross.case", title: "Medical", subtitle: "Dr. Wijaya") { activeSheet = .medical}
                        GridCard(icon: "doc.text", title: "Additions", subtitle: "3 notes") { activeSheet = .notes }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 10)
            }
            .background(Color(red: 0.96, green: 0.95, blue: 0.93))
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top) {
                HStack {
                    Button(action: { activeSheet = .newCat }) {
                        HStack {
                            Image(systemName: "cat")
                            Text("Mochi")
                            Image(systemName: "chevron.down")
                        }
                        .padding(10)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .foregroundColor(.brown)
                    }
                    .padding(.leading, 10)
                    Spacer()
                    Button {
                        activeSheet = .account
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .padding(10)
                            .background(Color.white)
                            .clipShape(Circle())
                            .foregroundColor(.brown)
                    }
                    .padding(.trailing, 20)
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.96, green: 0.95, blue: 0.93))
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .newCat:      NewCatView()
            case .personality: PersonalityFlowSheet()
            case .routine:     EditRoutineView()
            case .basicCare:   EditBasicCareView()
            case .preferences: EditPreferencesView()
            case .caution:     EditCautionView()
            case .medical:     EditMedicalView()
            case .notes:       AdditionalPageView()
            case .share:       ShareView()
            case .editCat:     EditCatProfileView()
            case .account:     AccountView()
            }
        }
    }
}

// MARK: - Reusable GridCard Component (Fixes your error!)
struct GridCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void // 1. Add an action property
    
    var body: some View {
        // 2. Wrap everything in a Button
        Button(action: action) {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .frame(width: 44, height: 44)
                        .background(Color(red: 0.93, green: 0.90, blue: 0.85))
                        .clipShape(Circle())
                        .foregroundColor(.black) // Keeps icon black
                    
                    Spacer()
                    
                    Image(systemName: "pencil")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .frame(width: 24, height: 24)
                        .background(Color(red: 0.96, green: 0.95, blue: 0.93))
                        .clipShape(Circle())
                }
                
                Spacer(minLength: 20)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.black.opacity(0.8))
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 2)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(20)
        }
        // 3. This stops SwiftUI from turning all the text inside the button blue!
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView(onSignOut: {})
}
