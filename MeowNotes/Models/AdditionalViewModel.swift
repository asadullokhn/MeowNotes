//
//  AdditionalViewModel.swift
//  MeowNotes
//
//  Created by Orenz on 28/05/26.
//

import SwiftUI
import Observation

@Observable
final class AdditionalViewModel {
    let predefinedTags = [
        "Hides when hears the vaccum.",
        "Wants attention before sleep.",
        "Doesn't like being picked up."
    ]
    
    var selectedTags: [TagItem] = []

    var availableTags: [String] = [
        "Hides when hears the vaccum.",
        "Wants attention before sleep.",
        "Doesn't like being picked up."
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

        selectedTags.insert(TagItem(text: trimmed), at: 0)   // newest sits right under the input
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
