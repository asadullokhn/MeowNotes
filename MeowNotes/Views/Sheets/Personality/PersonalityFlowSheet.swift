//
//  PersonalityFlowSheet.swift
//  MeowNotes
//
//  Created by Orenz on 28/05/26.
//

import SwiftUI

struct PersonalityFlowSheet: View {
    @State private var vm = PersonalityViewModel()
    
    var body: some View {
        NavigationStack {
            PersonalityPageView(vm: vm)
        }
    }
}
#Preview {
    PersonalityFlowSheet()
}
