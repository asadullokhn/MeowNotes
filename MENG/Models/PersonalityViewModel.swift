//
//  PersonalityViewModel.swift
//  MENG
//
//  Created by Orenz on 26/05/26.
//

import SwiftUI
import Observation

@Observable
final class PersonalityViewModel {
    let predefinedTags = [
        "shy with strangers",
        "playful",
        "clingy",
        "territorial",
        "sun bather",
        "window-watcher",
        "climbs everything",
        "talkative",
        "sleeps a lot",
        "fearless",
        "greets visitors"
    ]

    var selectedTags: [String] = []

    var availableTags: [String] = [
        "shy with strangers",
        "playful",
        "clingy",
        "territorial",
        "sun bather",
        "window-watcher",
        "climbs everything",
        "talkative",
        "sleeps a lot",
        "fearless",
        "greets visitors"
    ]

    var customAvailableTags: [String] = []

    var newTag: String = ""

    var notes: String = ""

    // How many times the note has been (re)generated. Rotates the on-device
    // template's intro and tip order so "Generate again" reads differently even
    // when the server generator is unavailable.
    var genCount = 0

    // Trait → what the sitter should actually do about it. Drives the on-device
    // fallback note; mirrors the web's TRAIT_GUIDE. Custom traits have no entry
    // and are simply skipped in the fallback (the server handles them when up).
    private let traitGuide: [String: String] = [
        "shy with strangers": "let them come to you instead of reaching out first",
        "playful": "keep a wand toy handy for a few minutes of play each visit",
        "loves brushing": "a quick brush is a great way to win them over",
        "clingy": "expect a shadow — they like company in the room",
        "territorial": "leave their usual spots and things where they are",
        "hates loud noises": "keep things quiet and give space during anything sudden or loud",
        "sun bather": "leave a sunny window spot within reach",
        "window-watcher": "keep a blind or curtain open so they can watch outside",
        "climbs everything": "don’t worry if you find them up high — it’s normal",
        "talkative": "expect plenty of meows — talking back is welcome",
        "sleeps a lot": "lots of napping is normal, so let them rest",
        "attention-seeker": "set aside a little one-on-one time each visit",
        "fearless": "still watch the door so they don’t slip out",
        "dignified": "let them approach on their own terms — don’t force cuddles",
        "vocal at 5 AM": "a dawn yowl usually just means breakfast",
        "greets visitors": "they’ll come say hello at the door",
    ]

    // MARK: - Functions
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
        let trimmed = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        selectedTags.insert(trimmed, at: 0)   // newest sits right under the input
        newTag = ""
    }

    func addCustomAvailableTag(_ tag: String) {
        customAvailableTags.removeAll { $0 == tag }
        selectedTags.append(tag)
    }

    func deleteCustomTag(_ tag: String) {
        customAvailableTags.removeAll { $0 == tag }
    }

    // On-device fallback note, built from the picked traits' guidance, used when
    // the server generator is unreachable so the button never dead-ends. Leads
    // with what to *do* (the traits already show as chips). Rotates the intro and
    // tip order by genCount so repeats feel fresh. Mirrors the web's
    // generateSummary(). Returns "" when no preset traits are selected.
    func localSummary(name: String) -> String {
        let tips = selectedTags.compactMap { traitGuide[$0] }
        guard !tips.isEmpty else { return "" }

        let intros = [
            "A few things that help with \(name):",
            "To keep \(name) comfortable:",
            "While you’re looking after \(name):",
        ]
        let intro = intros[genCount % intros.count]
        let ordered = genCount % 2 == 1 ? Array(tips.reversed()) : tips
        let body = ordered.joined(separator: "; ")
        let capitalized = body.prefix(1).uppercased() + body.dropFirst()
        return "\(intro) \(capitalized)."
    }
}
