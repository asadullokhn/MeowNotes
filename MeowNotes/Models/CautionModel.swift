//
//  CautionModel.swift
//  MeowNotes
//
//  Created by Yimei Winata on 28/05/26.
//

import Foundation
import SwiftData

struct CautionModel: Identifiable, Equatable {
    let id: UUID
    var text: String
    
    init(id: UUID = UUID(), text: String) {
        self.id = id
        self.text = text
    }
}

extension CautionModel {
    static let predefined: [CautionModel] = [
        CautionModel(text: "Can't eat fish or dairy."),
        CautionModel(text: "Bolts for the door — keep it shut."),
        CautionModel(text: "Never let outside."),
        CautionModel(text: "Bites when overstimulated."),
        CautionModel(text: "Medication twice a day — don't skip.")
    ]
}
