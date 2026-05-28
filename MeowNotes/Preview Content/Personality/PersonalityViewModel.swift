//
//  PersonalityViewModel.swift
//  MeowNotes
//
//  Created by Orenz on 26/05/26.
//

import SwiftUI

class PersonalityViewModel: ObservableObject {
    // MARK: - Predefined
    let predefinedTags = [
        "shy with strangers",
        "playful",
        "loves brushing",
        "clingy",
        "territorial",
        "hates loud noises",
        "sun bather",
        "window-watcher",
        "climbs everything",
        "talkative",
        "sleeps a lot",
        "attention-seeker",
        "fearless",
        "dignified",
        "greets visitors"
    ]

    // MARK: - Published State
    @Published var selectedTags: [String] = []
    @Published var availableTags: [String] = [
        "shy with strangers",
        "playful",
        "loves brushing",
        "clingy",
        "territorial",
        "hates loud noises",
        "sun bather",
        "window-watcher",
        "climbs everything",
        "talkative",
        "sleeps a lot",
        "attention-seeker",
        "fearless",
        "dignified",
        "greets visitors"
    ]
    
    @Published var customAvailableTags: [String] = []
    @Published var newTag = ""

    // MARK: - Actions
    func addTag(_ tag: String) {
        availableTags.removeAll { $0 == tag }
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
        let trimmed = newTag
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
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
}
