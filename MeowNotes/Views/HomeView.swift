

import SwiftUI

enum HomeSheet: String, Identifiable {
    case newCat, personality, routine, basicCare, preferences, caution, medical, notes, share
    var id: String { rawValue }
}

struct HomeView: View {
    var onSignOut: () -> Void

    @State private var activeSheet: HomeSheet?
    @State private var showAccount = false
    @State private var showGuide = false

    var body: some View {
        NavigationStack {
            List {
                Section("Cat sections") {
                    Card(title: "Personality")  { activeSheet = .personality }
                    Card(title: "Routine")      { activeSheet = .routine }
                    Card(title: "Basic Care")   { activeSheet = .basicCare }
                    Card(title: "Preferences")  { activeSheet = .preferences }
                    Card(title: "Caution")      { activeSheet = .caution }
                    Card(title: "Medical")      { activeSheet = .medical }
                    Card(title: "Notes")        { activeSheet = .notes }
                }
                Section("Actions") {
                    Card(title: "Add new cat")  { activeSheet = .newCat }
                    Card(title: "Share")        { activeSheet = .share }
                }
                Section("Other screens") {
                    Button("Open Account") { showAccount = true }
                    Button("Open Guide")   { showGuide = true }
                }
            }
            .navigationTitle("MeowNotes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Sign out", action: onSignOut)
                }
            }
            .navigationDestination(isPresented: $showAccount) { AccountView() }
            .navigationDestination(isPresented: $showGuide)   { GuideView() }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .newCat:      NewCatView()
                case .personality: EditPersonalityView()
                case .routine:     EditRoutineView()
                case .basicCare:   EditBasicCareView()
                case .preferences: EditPreferencesView()
                case .caution:     EditCautionView()
                case .medical:     EditMedicalView()
                case .notes:       EditNotesView()
                case .share:       ShareView()
                }
            }
        }
    }
}

private struct Card: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            }
        }
        .foregroundStyle(.primary)
    }
}

#Preview {
    HomeView(onSignOut: {})
}
