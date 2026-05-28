//
//  PersonalityFlowPage.swift
//  MeowNotes
//
//  Created by Orenz on 28/05/26.
//

import SwiftUI

struct PersonalityFlowPage: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = PersonalityViewModel()
    
    var body: some View {
        NavigationStack {
            PersonalityPageView(vm: vm)
        }
    }
}
#Preview {
    PersonalityFlowPage()
}
