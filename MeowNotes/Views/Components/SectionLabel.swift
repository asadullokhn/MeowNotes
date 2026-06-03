import SwiftUI

// The uppercase "eyebrow" caption that sits above a section of chips or a form
// field. `dimmed` is the quieter variant used for form-field labels.
struct SectionLabel: View {
    let title: String
    var dimmed: Bool = false

    init(_ title: String, dimmed: Bool = false) {
        self.title = title
        self.dimmed = dimmed
    }

    var body: some View {
        Text(title.uppercased())
            .font(.caption.weight(.bold))
            .tracking(0.5)
            .foregroundStyle(Color(.text).opacity(dimmed ? 0.5 : 1))
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        SectionLabel("Common ones")
        SectionLabel("Name", dimmed: true)
    }
    .padding()
    .background(Color("AppBg"))
}
