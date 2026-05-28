//
//  EditCatProfileView.swift
//  MeowNotes
//
//  Created by Gian Denggan Benjamin on 28/05/26.
//
import SwiftUI

struct EditCatProfileView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("A little more about them")
                    .font(.title.bold())
                Text("Name")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
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
        }
    }
}

#Preview { EditCatProfileView() }
