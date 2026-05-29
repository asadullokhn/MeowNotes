//
//  ShareIconButton.swift
//  MeowNotes
//
//  Created by Yimei Winata on 28/05/26.
//

import SwiftUI

struct ShareIconButton: View {
    let icon: String
    let label: String
    let color: Color
    let bgColor: Color
 
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(bgColor)
                    .frame(width: 56, height: 56)
 
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
            }
 
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color("TextBrown").opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}
