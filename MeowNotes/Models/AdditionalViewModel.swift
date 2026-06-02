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
    
    var selectedTags: [String] = []
    
    var availableTags: [String] = [
        "Hides when hears the vaccum.",
        "Wants attention before sleep.",
        "Doesn't like being picked up."
    ]
    
    var customAvailableTags: [String] = []
    
    var newTag: String = ""
    
    // MARK: - Functions
    func addTag(_ tag: String) {
        selectedTags.append(tag)
    }
    
    func removeTag(_ tag: String) {
        selectedTags.removeAll { $0 == tag }
        
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
        
        selectedTags.append(trimmed)
        newTag = ""
    }
    
    func addCustomAvailableTag(_ tag: String) {
        customAvailableTags.removeAll { $0 == tag }
        selectedTags.append(tag)
    }
    
    func deleteCustomTag(_ tag: String) {
        customAvailableTags.removeAll { $0 == tag }
    }
    
    func updateTag(old: String, new: String) {
        guard let index = selectedTags.firstIndex(of: old) else { return }
        
        selectedTags[index] = new
    }
}
