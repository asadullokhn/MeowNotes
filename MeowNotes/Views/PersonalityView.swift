import SwiftUI

struct PersonalityView: View {
    enum Personality: String, CaseIterable, Identifiable {
        case curious = "Curious"
        case grumpy = "Grumpy"
        case sleepy = "Sleepy"
        case playful = "Playful"

        var id: Self { self }

        var emoji: String {
            switch self {
            case .curious: "🐱"
            case .grumpy: "😾"
            case .sleepy: "😴"
            case .playful: "😸"
            }
        }
    }

    @State private var selected: Personality = .curious

    var body: some View {
        VStack(spacing: 24) {
            Text(selected.emoji)
                .font(.system(size: 96))

            Text(selected.rawValue)
                .font(.title)
                .fontWeight(.semibold)

            Picker("Personality", selection: $selected) {
                ForEach(Personality.allCases) { p in
                    Text(p.rawValue).tag(p)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
        }
        .padding()
        .navigationTitle("Cat Personality")
    }
}

#Preview {
    NavigationStack {
        PersonalityView()
    }
}
