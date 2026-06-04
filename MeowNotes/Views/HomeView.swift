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
        [cat?.breed, cat?.ageDisplay]
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
        if cat.checkCount == 0   { out.append(.init(title: "Daily Check", sheet: .basicCare)) }
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
                    .foregroundStyle(Color(.text))
                Text("Still to add for \(catName)'s guide — tap to fill in:")
                    .font(.footnote)
                    .foregroundStyle(Color(.text).opacity(0.7))
            }
            .padding(.trailing, 28)

            FlowLayout(spacing: 8) {
                ForEach(missingSections) { section in
                    Button { activeSheet = section.sheet } label: {
                        Text("+ \(section.title)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color(.text))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Color("AppBg"), in: Capsule())
                            .overlay(Capsule().stroke(Color(.bubbleBorder), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.bubbleBg), in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(.bubbleBorder), lineWidth: 1)
        )
        .overlay(alignment: .topTrailing) {
            Button { withAnimation { hintDismissed = true } } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color(.text).opacity(0.5))
                    .frame(width: 28, height: 28)
            }
            .accessibilityLabel("Dismiss")
            .padding(6)
        }
        .padding(.horizontal, 20)
    }

    var body: some View {
        NavigationStack {
            // Using a ScrollView so the grid can scroll on smaller screens
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // MARK: - Hero Image
                    // The photo is an overlay on a fixed-size container so its
                    // scaledToFill overflow is clipped here and can never leak into
                    // the layout — otherwise an off-aspect cropped photo shifts the
                    // whole screen's margins (the default asset happened not to).
                    Color.gray.opacity(0.3)
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .overlay {
                            CachedCatImage(cat?.photo) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Image("Cat").resizable().scaledToFill()
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .overlay(alignment: .bottomLeading) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(catName)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.3), radius: 3)

                                if !catSubtitle.isEmpty {
                                    Text(catSubtitle)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.9))
                                        .shadow(color: .black.opacity(0.3), radius: 3)
                                }
                            }
                            .padding(20)
                            // Name + breed/age read as one heading, not two stray bits.
                            .accessibilityElement(children: .combine)
                            .accessibilityAddTraits(.isHeader)
                        }
                        .overlay(alignment: .topTrailing) {
                            Button(action: { activeSheet = .editCat }) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(width: 44, height: 44)
                                    .background(.black.opacity(0.4), in: Circle())
                            }
                            .accessibilityLabel("Edit profile")
                            .padding(12)
                        }
                        // The whole hero opens the cat's profile, like the grid cards.
                        .contentShape(RoundedRectangle(cornerRadius: 30))
                        .onTapGesture { activeSheet = .editCat }
                        .padding(.horizontal, 20)
                    
                    // MARK: - Share Banner
                    Button(action: { activeSheet = .share }) {
                        HStack(spacing: 10) {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share \(catName)'s Care Guide")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .frame(height: 75)
                        .frame(maxWidth: .infinity)
                        .background(Color(.saveBg), in: RoundedRectangle(cornerRadius: 20))
                    }
                    .padding(.horizontal, 20)

                    // MARK: - Setup hint — sections still to fill in
                    if !hintDismissed && !missingSections.isEmpty {
                        setupHint
                    }

                    // MARK: - 2-Column Grid
                    LazyVGrid(columns: columns, spacing: 16) {
                        GridCard(icon: "pawprint", title: "Personality", subtitle: personalitySubtitle) { activeSheet = .personality }
                        GridCard(icon: "clock", title: "Routine", subtitle: routineSubtitle) { activeSheet = .routine }
                        GridCard(icon: "list.bullet", title: "Daily Check", subtitle: basicCareSubtitle) { activeSheet = .basicCare }
                        GridCard(icon: "exclamationmark.triangle", title: "Caution", subtitle: cautionSubtitle) { activeSheet = .caution }
                        GridCard(icon: "cross.case", title: "Medical", subtitle: medicalSubtitle) { activeSheet = .medical}
                        GridCard(icon: "doc.text", title: "Additions", subtitle: notesSubtitle) { activeSheet = .notes }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 10)
            }
            .background(Color("AppBg"))
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
                        .background(Color(.bubbleBg))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(Color(.text))
                    }
                    .padding(.leading, 20)
                    Spacer()
                    Button {
                        showAccount = true
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .padding(10)
                            .background(Color(.bubbleBg))
                            .clipShape(Circle())
                            .foregroundStyle(Color(.text))
                    }
                    .accessibilityLabel("Settings")
                    .padding(.trailing, 20)
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(Color("AppBg"))
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
        Button(action: { Haptics.tap(); action() }) {
            VStack(alignment: .leading) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .frame(width: 44, height: 44)
                    .background(Color("AppBg"))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color(.bubbleBorder), lineWidth: 1))
                    .foregroundStyle(Color(.text))

                Spacer(minLength: 20)

                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(.text))

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color(.text).opacity(0.6))
                    .padding(.top, 2)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.bubbleBg), in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.bubbleBorder), lineWidth: 1)
            )
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
