// Owner: TBD (claim by editing this line)
//
// Modal editor for the cat's Medical info (vet, vaccines, medications).
// Presented from HomeView. Ported from MochiApp's EditMedicalSheet.vue —
// same UI, using the app's dark-aware named colors.

import SwiftUI

struct EditMedicalView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var auth

    // Local editing state — not yet persisted (matches the other Edit sheets).
    // Seeded with the sample data the web reference ships with.
    @State private var vet = VetContact(
        name: "Dr. Wijaya",
        clinic: "Bali Pet Clinic",
        phone: "+62 812 5555 0100",
        address: "Jl. Sunset Rd 88, Kuta"
    )
    @State private var vaccines: [Vaccine] = [
        Vaccine(name: "FVRCP", last: "Feb 12, 2026", next: "Feb 2027"),
        Vaccine(name: "Rabies", last: "May 25, 2025", next: "May 25, 2026")
    ]
    @State private var medications: [Medication] = [
        Medication(name: "Joint vitamin", dose: "½ tab", schedule: "Daily, with breakfast")
    ]
    @State private var openRow: Row?

    private let commonVaccines = ["FVRCP", "Rabies", "FeLV"]
    private var catName: String { auth.currentCat?.name ?? "your cat" }

    enum Row: String, CaseIterable, Identifiable {
        case vet, vaccines, medications
        var id: String { rawValue }

        var icon: String {
            switch self {
            case .vet:         "cross.case.fill"
            case .vaccines:    "syringe"
            case .medications: "pills.fill"
            }
        }
        var label: String {
            switch self {
            case .vet:         "Vet contact"
            case .vaccines:    "Vaccinations"
            case .medications: "Medications"
            }
        }
    }

    private func summary(for row: Row) -> String {
        switch row {
        case .vet:         vet.name.trimmingCharacters(in: .whitespaces).isEmpty ? "Not set" : vet.name
        case .vaccines:    "\(vaccines.count) tracked"
        case .medications: "\(medications.count) tracked"
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        (
                            Text("Health & ")
                            + Text("vet").italic().font(.system(size: 30, weight: .bold, design: .serif))
                            + Text(".")
                        )
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(Color(.text))

                        Text("Tap a row to fill it in — one thing at a time.")
                            .font(.subheadline)
                            .foregroundStyle(Color(.text).opacity(0.6))
                            .padding(.top, 6)
                            .padding(.bottom, 18)

                        VStack(spacing: 10) {
                            ForEach(Row.allCases) { row in
                                rowCard(row)
                            }
                        }
                        .animation(.spring(response: 0.32, dampingFraction: 0.85), value: openRow)
                    }
                    .padding()
                }

                footer
            }
            .background(Color(.background))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text(catName.uppercased() + " · MEDICAL")
                        .fixedSize()
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(.text))
                }
                .sharedBackgroundVisibility(.hidden)

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 12, height: 12)
                    }
                }
            }
        }
    }

    // MARK: - Row

    private func rowCard(_ row: Row) -> some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                    openRow = (openRow == row) ? nil : row
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: row.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(.text).opacity(0.7))
                        .frame(width: 36, height: 36)
                        .background(Color(.bubbleSectionBg), in: RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(row.label)
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(Color(.text))
                        Text(summary(for: row))
                            .font(.caption)
                            .foregroundStyle(Color(.text).opacity(0.55))
                    }

                    Spacer(minLength: 8)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color(.text).opacity(0.4))
                        .rotationEffect(.degrees(openRow == row ? 90 : 0))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if openRow == row {
                Rectangle()
                    .fill(Color(.bubbleBorder))
                    .frame(height: 1)

                Group {
                    switch row {
                    case .vet:         vetEditor
                    case .vaccines:    vaccinesEditor
                    case .medications: medicationsEditor
                    }
                }
                .padding(14)
                .transition(.opacity)
            }
        }
        .background(Color(.bubbleBg), in: RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(.bubbleBorder), lineWidth: 1)
        )
    }

    // MARK: - Vet

    private var vetEditor: some View {
        VStack(alignment: .leading, spacing: 12) {
            labeledField("Vet name", placeholder: "Dr. Wijaya", text: $vet.name)
            labeledField("Clinic", placeholder: "Bali Pet Clinic", text: $vet.clinic)
            labeledField("Phone", placeholder: "+62 812 5555 0100", text: $vet.phone, keyboard: .phonePad)
            labeledField("Address · optional", placeholder: "Jl. Sunset Rd 88, Kuta", text: $vet.address)
        }
    }

    // MARK: - Vaccinations

    private var vaccinesEditor: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach($vaccines) { $vaccine in
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        inputField("FVRCP", text: $vaccine.name, fill: Color(.bubbleBg), bold: true)
                        removeButton { vaccines.removeAll { $0.id == vaccine.id } }
                    }
                    HStack(spacing: 8) {
                        inputField("Last · Feb 2026", text: $vaccine.last, fill: Color(.bubbleBg))
                        inputField("Next · Feb 2027", text: $vaccine.next, fill: Color(.bubbleBg))
                    }
                }
                .padding(10)
                .background(Color(.bubbleSectionBg), in: RoundedRectangle(cornerRadius: 14))
            }

            FlowLayout(spacing: 8) {
                ForEach(commonVaccines.filter { name in !vaccines.contains { $0.name == name } }, id: \.self) { name in
                    Button {
                        vaccines.append(Vaccine(name: name, last: "", next: ""))
                    } label: {
                        chip("+ \(name)", dashed: false)
                    }
                    .buttonStyle(.plain)
                }
                Button {
                    vaccines.append(Vaccine(name: "", last: "", next: ""))
                } label: {
                    chip("+ Custom", dashed: true)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Medications

    private var medicationsEditor: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach($medications) { $med in
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        inputField("Joint vitamin", text: $med.name, fill: Color(.bubbleBg), bold: true)
                        removeButton { medications.removeAll { $0.id == med.id } }
                    }
                    HStack(spacing: 8) {
                        inputField("½ tab", text: $med.dose, fill: Color(.bubbleBg))
                        inputField("Daily with breakfast", text: $med.schedule, fill: Color(.bubbleBg))
                    }
                }
                .padding(10)
                .background(Color(.bubbleSectionBg), in: RoundedRectangle(cornerRadius: 14))
            }

            Button {
                medications.append(Medication(name: "", dose: "", schedule: ""))
            } label: {
                Text("+ Add medication")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color(.text).opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color(.bubbleBorder), style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                    )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color(.bubbleBorder))
                .frame(height: 1)

            HStack(spacing: 10) {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(.text))
                        .frame(maxWidth: 110)
                        .frame(height: 52)
                        .background(Color(.bubbleBg))
                        .clipShape(RoundedRectangle(cornerRadius: 26))
                        .overlay(
                            RoundedRectangle(cornerRadius: 26)
                                .stroke(Color(.bubbleBorder), lineWidth: 1)
                        )
                }

                Button {
                    dismiss()
                } label: {
                    Text("Save medical")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(.saveBg))
                        .clipShape(RoundedRectangle(cornerRadius: 26))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(.background))
    }

    // MARK: - Field helpers

    private func labeledField(
        _ title: String,
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.caption2.weight(.semibold))
                .tracking(0.5)
                .foregroundStyle(Color(.text).opacity(0.5))
            inputField(placeholder, text: text, fill: Color(.bubbleSectionBg), keyboard: keyboard)
        }
    }

    private func inputField(
        _ placeholder: String,
        text: Binding<String>,
        fill: Color,
        bold: Bool = false,
        keyboard: UIKeyboardType = .default
    ) -> some View {
        TextField(placeholder, text: text)
            .font(.subheadline.weight(bold ? .semibold : .regular))
            .foregroundStyle(Color(.text))
            .keyboardType(keyboard)
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(fill, in: RoundedRectangle(cornerRadius: 12))
    }

    private func removeButton(_ action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { action() }
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color(.text).opacity(0.55))
                .frame(width: 28, height: 28)
                .background(Color(.bubbleBg), in: Circle())
        }
        .buttonStyle(.plain)
    }

    private func chip(_ text: String, dashed: Bool) -> some View {
        Text(text)
            .font(.caption.weight(.medium))
            .foregroundStyle(Color(.text).opacity(0.75))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(.bubbleSectionBg), in: Capsule())
            .overlay(
                Capsule()
                    .stroke(
                        Color(.bubbleBorder),
                        style: StrokeStyle(lineWidth: 1, dash: dashed ? [4] : [])
                    )
            )
    }
}

// Local editing models — kept here while Medical isn't persisted server-side.
private struct VetContact {
    var name: String
    var clinic: String
    var phone: String
    var address: String
}

private struct Vaccine: Identifiable {
    let id = UUID()
    var name: String
    var last: String
    var next: String
}

private struct Medication: Identifiable {
    let id = UUID()
    var name: String
    var dose: String
    var schedule: String
}

#Preview {
    EditMedicalView()
        .environment(AuthManager())
}
