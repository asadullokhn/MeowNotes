//
//  PersonalityFlowSheet.swift
//  MENG
//
//  Created by Orenz on 28/05/26.
//

import SwiftUI

struct PersonalityFlowSheet: View {
    var onSaved: () -> Void = {}
    @State private var vm = PersonalityViewModel()
    @Environment(AuthManager.self) private var auth

    var body: some View {
        NavigationStack {
            PersonalityPageView(vm: vm, onSaved: onSaved)
        }
        .onAppear(perform: load)
    }

    private func load() {
        guard let cat = auth.currentCat else { return }
        if vm.selectedTags.isEmpty {
            vm.selectedTags = cat.personality ?? []
            vm.availableTags.removeAll { vm.selectedTags.contains($0) }
        }
        vm.notes = cat.personalitySummary ?? ""
    }
}
#Preview {
    PersonalityFlowSheet()
}
