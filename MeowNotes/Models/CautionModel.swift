//
//  CautionModel.swift
//  MeowNotes
//
//  Created by Yimei Winata on 28/05/26.
//

import Foundation
import SwiftData

import Observation

@Observable
final class CautionModel {
    let predefinedTags = [
        "Can't eat fish or dairy.",
        "Bolts for the door — keep it shut.",
        "Never let outside.",
        "Bites when overstimulated.",
        "Medication twice a day — don't skip."
    ]
    
    var selectedTags: [TagItem] = []

    var availableTags: [String] = [
        "Can't eat fish or dairy.",
        "Bolts for the door — keep it shut.",
        "Never let outside.",
        "Bites when overstimulated.",
        "Medication twice a day — don't skip."
    ]
    
    var customAvailableTags: [String] = []
    
    var newTag: String = ""
    
    // MARK: - Functions
    func addTag(_ tag: String) {
        selectedTags.append(TagItem(text: tag))
    }

    func removeTag(_ item: TagItem) {
        selectedTags.removeAll { $0.id == item.id }

        let tag = item.text
        if predefinedTags.contains(tag) {
            if !availableTags.contains(tag) {
                availableTags.append(tag)
            }
        } else {
            if !customAvailableTags.contains(tag) {
                customAvailableTags.append(tag)
            }
        }
    }

    func addCustomTag() {
        let trimmed = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        selectedTags.append(TagItem(text: trimmed))
        newTag = ""
    }

    func addCustomAvailableTag(_ tag: String) {
        customAvailableTags.removeAll { $0 == tag }
        selectedTags.append(TagItem(text: tag))
    }
    
    func deleteCustomTag(_ tag: String) {
        customAvailableTags.removeAll { $0 == tag }
    }
}


//struct CautionModel: Identifiable, Equatable {
//    let id: UUID
//    var text: String
//
//    init(id: UUID = UUID(), text: String) {
//        self.id = id
//        self.text = text
//    }
//}
//
//extension CautionModel {
//    static let predefined: [CautionModel] = [
//        CautionModel(text: "Can't eat fish or dairy."),
//        CautionModel(text: "Bolts for the door — keep it shut."),
//        CautionModel(text: "Never let outside."),
//        CautionModel(text: "Bites when overstimulated."),
//        CautionModel(text: "Medication twice a day — don't skip.")
//    ]
//}
