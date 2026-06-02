import SwiftUI

enum HomeSheet: String, Identifiable {
    case newCat, personality, routine, basicCare, caution, medical, notes, share, editCat
    var id: String { rawValue }
}

// 1. Define a 2-column layout with flexible widths and spacing
let columns = [
    GridItem(.flexible(), spacing: 16),
    GridItem(.flexible(), spacing: 16)
]

struct HomeView: View {
    var onSignOut: () -> Void
    @Environment(AuthManager.self) private var auth
    @State private var activeSheet: HomeSheet?
    @State private var showAccount = false
    // Setup-hint visibility. Unlike the web (dismissed forever in localStorage),
    // we only hide it for this session so it gently returns next launch.
    @State private var hintDismissed = false

    private var cat: Cat? { auth.currentCat }
    private var catName: String { cat?.name ?? "Your cat" }
    private var catSubtitle: String {
        [cat?.breed, cat?.age?.display]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }

    // Home-grid subtitles, derived from the current cat (mirrors Home.vue).
    private var personalitySubtitle: String {
        let n = cat?.traitCount ?? 0
        return n > 0 ? "\(n) trait\(n == 1 ? "" : "s")" : "Not set yet"
    }
    private var routineSubtitle: String {
        let n = cat?.routineCount ?? 0
        return n > 0 ? "\(n) thing\(n == 1 ? "" : "s") a day" : "Not set yet"
    }
    private var basicCareSubtitle: String {
        let n = cat?.checkCount ?? 0
        return n > 0 ? "\(n) quick check\(n == 1 ? "" : "s")" : "Not set yet"
    }
    private var cautionSubtitle: String {
        let n = cat?.cautionCount ?? 0
        return n > 0 ? "\(n) thing\(n == 1 ? "" : "s") flagged" : "Nothing flagged"
    }
    private var medicalSubtitle: String { cat?.vetName ?? "No vet on file" }
    private var notesSubtitle: String {
        let n = cat?.noteCount ?? 0
        return n > 0 ? "\(n) note\(n == 1 ? "" : "s")" : "Not set yet"
    }

    // What's still empty for this cat — drives the setup hint (mirrors Home.vue).
    private var missingSections: [MissingSection] {
        guard let cat else { return [] }
        var out: [MissingSection] = []
        if cat.traitCount == 0   { out.append(.init(title: "Personality", sheet: .personality)) }
        if cat.routineCount == 0 { out.append(.init(title: "Routine", sheet: .routine)) }
        if cat.checkCount == 0   { out.append(.init(title: "Basic Care", sheet: .basicCare)) }
        if cat.cautionCount == 0 { out.append(.init(title: "Caution", sheet: .caution)) }
        if cat.vetName == nil    { out.append(.init(title: "Medical", sheet: .medical)) }
        if cat.noteCount == 0    { out.append(.init(title: "Additions", sheet: .notes)) }
        return out
    }

    // Soft, dismissible banner of the sections still to fill in. Tapping a pill
    // opens that section's editor.
    private var setupHint: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14))
                    .foregroundColor(.brown)
                Text("Still to add for \(catName)'s guide — tap to fill in:")
                    .font(.footnote)
                    .foregroundColor(.brown)
            }
            .padding(.trailing, 28)

            FlowLayout(spacing: 8) {
                ForEach(missingSections) { section in
                    Button { activeSheet = section.sheet } label: {
                        Text("+ \(section.title)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.brown)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Color.white, in: Capsule())
                            .overlay(Capsule().stroke(Color.brown.opacity(0.15), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.brown.opacity(0.08), in: RoundedRectangle(cornerRadius: 20))
        .overlay(alignment: .topTrailing) {
            Button { withAnimation { hintDismissed = true } } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.brown.opacity(0.5))
                    .frame(width: 28, height: 28)
            }
        }
        .padding(.horizontal, 20)
    }

    var body: some View {
        NavigationStack {
            // Using a ScrollView so the grid can scroll on smaller screens
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Hero Image
                    ZStack(alignment: .bottomLeading) {
                        AsyncImage(url: URL(string: cat?.photo ?? "")) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Image("Cat").resizable().scaledToFill()
                        }
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
                            Text(catName)
                                .font(.headline)
                                .foregroundColor(.white)

                            if !catSubtitle.isEmpty {
                                Text(catSubtitle)
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }
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
                                Text("Share \(catName)'s Care Guide")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 40)
                        }
                    }

                    // MARK: - Setup hint — sections still to fill in
                    if !hintDismissed && !missingSections.isEmpty {
                        setupHint
                    }

                    // MARK: - 2-Column Grid
                    LazyVGrid(columns: columns, spacing: 16) {
                        GridCard(icon: "pawprint", title: "Personality", subtitle: personalitySubtitle) { activeSheet = .personality }
                        GridCard(icon: "clock", title: "Routine", subtitle: routineSubtitle) { activeSheet = .routine }
                        GridCard(icon: "list.bullet", title: "Basic Care", subtitle: basicCareSubtitle) { activeSheet = .basicCare }
                        GridCard(icon: "exclamationmark.triangle", title: "Caution", subtitle: cautionSubtitle) { activeSheet = .caution }
                        GridCard(icon: "cross.case", title: "Medical", subtitle: medicalSubtitle) { activeSheet = .medical}
                        GridCard(icon: "doc.text", title: "Additions", subtitle: notesSubtitle) { activeSheet = .notes }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 10)
            }
            .background(Color(red: 0.96, green: 0.95, blue: 0.93))
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top) {
                HStack {
                    Menu {
                        ForEach(auth.cats) { c in
                            Button {
                                auth.selectCat(c.id)
                            } label: {
                                if c.id == cat?.id {
                                    Label(c.name, systemImage: "checkmark")
                                } else {
                                    Text(c.name)
                                }
                            }
                        }
                        Divider()
                        Button {
                            activeSheet = .newCat
                        } label: {
                            Label("Add new cat", systemImage: "plus")
                        }
                    } label: {
                        HStack {
                            Image(systemName: "cat")
                            Text(catName)
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
                        showAccount = true
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
            .navigationDestination(isPresented: $showAccount) { AccountView() }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .newCat:      WelcomeView(isAdditional: true)
            case .personality: PersonalityFlowSheet(onSaved: { activeSheet = nil })
            case .routine:     EditRoutineView()
            case .basicCare:   EditBasicCareView()
            case .caution:     EditCautionView()
            case .medical:     EditMedicalView()
            case .notes:       AdditionalPageView()
            case .share:       ShareView()
            case .editCat:     EditCatProfileView()
            }
        }
    }
}

// One still-empty section surfaced in the setup hint.
private struct MissingSection: Identifiable {
    let id = UUID()
    let title: String
    let sheet: HomeSheet
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
        .environment(AuthManager())
        .preferredColorScheme(.dark)
}
