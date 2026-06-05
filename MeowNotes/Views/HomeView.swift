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
    // Compact card grid vs. an expanded full-guide layout. Remembered across launches.
    @AppStorage("homeExpandedLayout") private var expandedLayout = false
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
    // The six categories, shared by both the grid and list layouts. `count` is
    // each section's own item count (0 = not set yet), driving the card's
    // not-set background.
    private var categories: [CategoryItem] {
        [
            CategoryItem(sheet: .personality, icon: "pawprint", title: "Personality", subtitle: personalitySubtitle, count: cat?.traitCount ?? 0),
            CategoryItem(sheet: .routine, icon: "clock", title: "Routine", subtitle: routineSubtitle, count: cat?.routineCount ?? 0),
            CategoryItem(sheet: .basicCare, icon: "checkmark", title: "Daily Check", subtitle: basicCareSubtitle, count: cat?.checkCount ?? 0),
            CategoryItem(sheet: .caution, icon: "exclamationmark.triangle", title: "Caution", subtitle: cautionSubtitle, count: cat?.cautionCount ?? 0),
            CategoryItem(sheet: .medical, icon: "cross.case", title: "Medical", subtitle: medicalSubtitle, count: cat?.vetName != nil ? 1 : 0),
            CategoryItem(sheet: .notes, icon: "doc.text", title: "Additions", subtitle: notesSubtitle, count: cat?.noteCount ?? 0)
        ]
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
                Text("Still to add for \(catName)'s guide — tap to fill in:")
                    .font(.footnote)
                    .foregroundStyle(Color(.text).opacity(0.7))
            }
            .padding(.trailing, 28)

            FlowLayout(spacing: 8) {
                ForEach(missingSections) { section in
                    Button { Haptics.tap(); activeSheet = section.sheet } label: {
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
            Button { Haptics.tap(); withAnimation { hintDismissed = true } } label: {
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
                            Button(action: { Haptics.tap(); activeSheet = .editCat }) {
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
                        .onTapGesture { Haptics.tap(); activeSheet = .editCat }
                        .padding(.horizontal, 20)

                    // MARK: - Share Banner
                    Button(action: { Haptics.tap(.medium); activeSheet = .share }) {
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

                    // MARK: - Care guide header + view toggle
                    HStack {
                        SectionLabel("Care guide")
                        Spacer()
                        Button {
                            Haptics.tap()
                            withAnimation(.easeInOut(duration: 0.2)) { expandedLayout.toggle() }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: expandedLayout ? "square.grid.2x2" : "list.bullet.rectangle")
                                    .font(.system(size: 13, weight: .semibold))
                                Text(expandedLayout ? "Cards" : "Guide")
                                    .font(.subheadline.weight(.medium))
                            }
                            .foregroundStyle(Color(.text))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(Color(.bubbleBg), in: Capsule())
                            .overlay(Capsule().stroke(Color(.bubbleBorder), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(expandedLayout ? "Switch to card view" : "Switch to guide view")
                    }
                    .padding(.horizontal, 20)

                    // MARK: - Categories — compact cards, or the full expanded guide
                    if expandedLayout {
                        ExpandedHomeView(cat: cat) { activeSheet = $0 }
                            .padding(.horizontal, 20)
                            .transition(.opacity)
                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(categories) { item in
                                GridCard(icon: item.icon, title: item.title, subtitle: item.subtitle, count: item.count) {
                                    activeSheet = item.sheet
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .transition(.opacity)
                    }
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
                                Haptics.tap()
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
                            Haptics.tap()
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
                        Haptics.tap()
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

// One home-screen category, rendered as either a grid card or a list row.
private struct CategoryItem: Identifiable {
    let sheet: HomeSheet
    var id: HomeSheet { sheet }
    let icon: String
    let title: String
    let subtitle: String
    let count: Int
}

// MARK: - Expanded guide variant — every section's content inline (vs. cards)
private struct ExpandedHomeView: View {
    let cat: Cat?
    let onOpen: (HomeSheet) -> Void

    var body: some View {
        VStack(spacing: 16) {
            personality
            routine
            dailyCheck
            caution
            medical
            additions
        }
    }

    // A section card: a tappable header (opens the editor) plus its content.
    @ViewBuilder
    private func section<Content: View>(_ icon: String, _ title: String, _ sheet: HomeSheet,
                                        @ViewBuilder content: () -> Content) -> some View {
        // The whole card is tappable (not just the header) — it opens the editor.
        Button { Haptics.tap(); onOpen(sheet) } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: icon)
                        .font(.system(size: 15))
                        .frame(width: 34, height: 34)
                        .background(Color("AppBg"))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color(.bubbleBorder), lineWidth: 1))
                        .foregroundStyle(Color(.text))
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color(.text))
                    Spacer()
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(.text).opacity(0.35))
                }

                content()
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.bubbleBg), in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.bubbleBorder), lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }

    private func emptyHint(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(Color(.text).opacity(0.4))
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var personality: some View {
        section("pawprint", "Personality", .personality) {
            let traits = cat?.personality ?? []
            let summary = cat?.personalitySummary ?? ""
            if traits.isEmpty && summary.isEmpty {
                emptyHint("No traits yet — tap to add.")
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    if !traits.isEmpty {
                        FlowLayout(spacing: 8) {
                            ForEach(traits, id: \.self) { trait in
                                Text(trait)
                                    .font(.subheadline)
                                    .foregroundStyle(Color(.text))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color("AppBg"), in: Capsule())
                                    .overlay(Capsule().stroke(Color(.bubbleBorder), lineWidth: 1))
                            }
                        }
                    }
                    if !summary.isEmpty {
                        Text(summary)
                            .font(.subheadline)
                            .foregroundStyle(Color(.text).opacity(0.75))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    private var routine: some View {
        section("clock", "Routine", .routine) {
            let items = cat?.feedingRoutine ?? []
            if items.isEmpty {
                emptyHint("Nothing scheduled — tap to add.")
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(items) { item in
                        HStack(alignment: .top, spacing: 10) {
                            Text(item.time.isEmpty ? "—" : item.time)
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(Color(.bubbleSelectedBg))
                                .frame(width: 66, alignment: .leading)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(item.title)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(Color(.text))
                                if !item.detail.isEmpty {
                                    Text(item.detail)
                                        .font(.caption)
                                        .foregroundStyle(Color(.text).opacity(0.6))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var dailyCheck: some View {
        section("checkmark", "Daily Check", .basicCare) {
            let checks = cat?.checks ?? []
            if checks.isEmpty {
                emptyHint("No checks yet — tap to add.")
            } else {
                VStack(alignment: .leading, spacing: 7) {
                    ForEach(checks) { check in
                        HStack(spacing: 8) {
                            Image(systemName: "circle")
                                .font(.system(size: 11))
                                .foregroundStyle(Color(.text).opacity(0.4))
                            Text(check.label)
                                .font(.subheadline)
                                .foregroundStyle(Color(.text))
                        }
                    }
                }
            }
        }
    }

    private var caution: some View {
        section("exclamationmark.triangle", "Caution", .caution) {
            let cautions = (cat?.notes ?? []).filter { $0.urgent == true }
            if cautions.isEmpty {
                emptyHint("Nothing flagged — tap to add.")
            } else {
                VStack(alignment: .leading, spacing: 7) {
                    ForEach(cautions) { note in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.system(size: 13))
                                .foregroundStyle(.red.opacity(0.7))
                            Text(note.text)
                                .font(.subheadline)
                                .foregroundStyle(Color(.text))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
    }

    private var medical: some View {
        section("cross.case", "Medical", .medical) {
            let med = cat?.medical
            let vet = med?.vet
            let vaccines = (med?.vaccines ?? []).filter { !$0.name.isEmpty }
            let meds = (med?.medications ?? []).filter { !$0.name.isEmpty }
            let hasVet = !(vet?.name.isEmpty ?? true) || !(vet?.clinic.isEmpty ?? true) || !(vet?.phone.isEmpty ?? true)
            if !hasVet && vaccines.isEmpty && meds.isEmpty {
                emptyHint("No medical info yet — tap to add.")
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    if hasVet, let vet {
                        VStack(alignment: .leading, spacing: 1) {
                            if !vet.name.isEmpty {
                                Text(vet.name)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(Color(.text))
                            }
                            let sub = [vet.clinic, vet.phone].filter { !$0.isEmpty }.joined(separator: " · ")
                            if !sub.isEmpty {
                                Text(sub)
                                    .font(.caption)
                                    .foregroundStyle(Color(.text).opacity(0.6))
                            }
                        }
                    }
                    ForEach(vaccines.indices, id: \.self) { i in
                        let v = vaccines[i]
                        let dates = [v.last.isEmpty ? nil : "last \(v.last)", v.next.isEmpty ? nil : "next \(v.next)"]
                            .compactMap { $0 }.joined(separator: ", ")
                        Text("Vaccine: \(v.name)" + (dates.isEmpty ? "" : " — \(dates)"))
                            .font(.subheadline)
                            .foregroundStyle(Color(.text))
                    }
                    ForEach(meds.indices, id: \.self) { i in
                        let m = meds[i]
                        let detail = [m.dose, m.schedule].filter { !$0.isEmpty }.joined(separator: " · ")
                        Text("Med: \(m.name)" + (detail.isEmpty ? "" : " — \(detail)"))
                            .font(.subheadline)
                            .foregroundStyle(Color(.text))
                    }
                }
            }
        }
    }

    private var additions: some View {
        section("doc.text", "Additions", .notes) {
            let adds = (cat?.notes ?? []).filter { $0.urgent != true }
            if adds.isEmpty {
                emptyHint("Nothing else yet — tap to add.")
            } else {
                VStack(alignment: .leading, spacing: 7) {
                    ForEach(adds) { note in
                        HStack(alignment: .top, spacing: 8) {
                            Circle()
                                .fill(Color(.bubbleSelectedBg))
                                .frame(width: 6, height: 6)
                                .padding(.top, 6)
                            Text(note.text)
                                .font(.subheadline)
                                .foregroundStyle(Color(.text))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Reusable GridCard Component
struct GridCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let count: Int
    let action: () -> Void

    var body: some View {
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
                    .foregroundStyle(Color("TitleColor"))

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color(.text).opacity(0.6))
                    .padding(.top, 2)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(count != 0 ? Color(.bubbleBg) : Color(.bubbleBorder), in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.bubbleBorder), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView(onSignOut: {})
        .environment(AuthManager())
}
