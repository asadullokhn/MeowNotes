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
    // `false` when `icon` names an asset-catalog image (e.g. a brand logo) rather
    // than an SF Symbol — rendered as a template so `color` still tints it.
    var isSystemImage: Bool = true

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(bgColor)
                    .frame(width: 56, height: 56)

                Group {
                    if isSystemImage {
                        Image(systemName: icon)
                            .font(.system(size: 22))
                    } else {
                        Image(icon)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 26, height: 26)
                    }
                }
                .foregroundColor(color)
            }
 
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color("TextBrown").opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}
