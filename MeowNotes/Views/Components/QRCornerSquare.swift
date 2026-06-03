//
//  QRCornerSquare.swift
//  MeowNotes
//
//  Created by Yimei Winata on 28/05/26.
//

import SwiftUI

struct QRCornerSquare: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color("SaveBg"))
                .frame(width: 24, height: 24)
            Rectangle()
                .fill(Color.white)
                .frame(width: 16, height: 16)
            Rectangle()
                .fill(Color("SaveBg"))
                .frame(width: 10, height: 10)
        }
    }
}
