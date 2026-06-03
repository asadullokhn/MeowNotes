// Owner: TBD (claim by editing this line)
//
// Modal editor for the cat's Medical info (vet, vaccines, medications).
// Presented from HomeView. Ported from MochiApp's EditMedicalSheet.vue —
// same UI, using the app's dark-aware named colors.

import SwiftUI

struct EditMedicalView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var auth

    // Local editing copies of the cat's medical record, hydrated from the
    // server in `load()` and PATCHed back in `save()`.
    @State private var vet = VetContact(name: "", clinic: "", phone: "", address: "")
    @State private var vaccines: [Vaccine] = []
    @State private var medications: [Medication] = []
    @State private var openRow: Row?
    @State private var saving = false
    @State private var errorMessage: String?
    @State private var initialSignature = ""
    @State private var loaded = false

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

    private var hasChanges: Bool { medicalSignature() != initialSignature }

    private func medicalSignature() -> String {
        let v = "\(vet.name)|\(vet.clinic)|\(vet.phone)|\(vet.address)"
        let vac = vaccines.map { "\($0.name)|\($0.last)|\($0.next)" }.joined(separator: ";")
        let med = medications.map { "\($0.name)|\($0.dose)|\($0.schedule)" }.joined(separator: ";")
        return "\(v)#\(vac)#\(med)"
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
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Health & vet.")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(Color(.text))

                        Text("Tap a row to fill it in — one thing at a time.")
                            .font(.subheadline)
                            .foregroundStyle(Color(.text))
                            .padding(.top, 6)
                            .padding(.bottom, 18)

                        VStack(spacing: 10) {
                            ForEach(Row.allCases) { row in
                                rowCard(row)
                            }
                        }
                        .animation(.spring(response: 0.32, dampingFraction: 0.85), value: openRow)

                        if let errorMessage {
                            AuthErrorBanner(message: errorMessage)
                                .padding(.top, 12)
                        }
                    }
                    .padding()
                }

            }
            .background(Color(.background))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                load()
                if !loaded { initialSignature = medicalSignature(); loaded = true }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color(.text))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    SaveToolbarButton(saving: saving, hasChanges: hasChanges, disabled: auth.currentCat == nil, action: save)
                }
            }
        }
    }

    // MARK: - Load / Save

    private func load() {
        guard let medical = auth.currentCat?.medical else { return }
        vet = VetContact(
            name: medical.vet.name,
            clinic: medical.vet.clinic,
            phone: medical.vet.phone,
            address: medical.vet.address
        )
        vaccines = medical.vaccines.map { Vaccine(name: $0.name, last: $0.last, next: $0.next) }
        medications = medical.medications.map { Medication(name: $0.name, dose: $0.dose, schedule: $0.schedule) }
    }

    private func save() {
        guard let catID = auth.currentCat?.id, !saving else { return }
        saving = true
        errorMessage = nil

        // Drop rows the user left blank, mirroring the web reference.
        let payload = Medical(
            vet: Medical.Vet(name: vet.name, clinic: vet.clinic, phone: vet.phone, address: vet.address),
            vaccines: vaccines
                .filter { !$0.name.trimmingCharacters(in: .whitespaces).isEmpty }
                .map { Medical.Vaccine(name: $0.name, last: $0.last, next: $0.next) },
            medications: medications
                .filter { !$0.name.trimmingCharacters(in: .whitespaces).isEmpty }
                .map { Medical.Medication(name: $0.name, dose: $0.dose, schedule: $0.schedule) }
        )

        Task {
            do {
                try await auth.updateMedical(catID: catID, payload)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
            saving = false
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
                        CareTextField(placeholder: "FVRCP", text: $vaccine.name, bold: true, fill: Color(.bubbleBg))
                        RemoveCircleButton(size: 28) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                vaccines.removeAll { $0.id == vaccine.id }
                            }
                        }
                    }
                    VaccineDateField(title: "Last given", value: $vaccine.last)
                    VaccineDateField(title: "Next due", value: $vaccine.next)
                }
                .padding(10)
                .background(Color(.bubbleSectionBg), in: RoundedRectangle(cornerRadius: 14))
            }

            FlowLayout(spacing: 8) {
                ForEach(commonVaccines.filter { name in !vaccines.contains { $0.name == name } }, id: \.self) { name in
                    AddBubble(text: name) {
                        vaccines.append(Vaccine(name: name, last: "", next: ""))
                    }
                }
                AddBubble(text: "Custom", dashed: true) {
                    vaccines.append(Vaccine(name: "", last: "", next: ""))
                }
            }
        }
    }

    // MARK: - Medications

    private var medicationsEditor: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach($medications) { $med in
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        CareTextField(placeholder: "Joint vitamin", text: $med.name, bold: true, fill: Color(.bubbleBg))
                        RemoveCircleButton(size: 28) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                medications.removeAll { $0.id == med.id }
                            }
                        }
                    }
                    HStack(spacing: 8) {
                        CareTextField(placeholder: "½ tab", text: $med.dose, fill: Color(.bubbleBg))
                        CareTextField(placeholder: "Daily with breakfast", text: $med.schedule, fill: Color(.bubbleBg))
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

    // MARK: - Field helpers

    private func labeledField(
        _ title: String,
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionLabel(title, dimmed: true)
            CareTextField(placeholder: placeholder, text: text, keyboard: keyboard, fill: Color(.bubbleSectionBg))
        }
    }
}

// An optional date for a vaccine's "last given" / "next due": a compact date
// picker, or an "Add date" prompt when unset. Stored as a readable string so the
// sitter guide shows it as-is; parses existing free-text dates best-effort.
private struct VaccineDateField: View {
    let title: String
    @Binding var value: String

    private static let display: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()

    private static func parse(_ raw: String) -> Date? {
        let trimmed = raw.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }
        if let d = display.date(from: trimmed) { return d }
        for pattern in ["MMM yyyy", "MMMM yyyy", "yyyy-MM-dd", "MM/dd/yyyy"] {
            let f = DateFormatter()
            f.locale = Locale(identifier: "en_US_POSIX")
            f.dateFormat = pattern
            if let d = f.date(from: trimmed) { return d }
        }
        return nil
    }

    private var date: Binding<Date> {
        Binding(
            get: { Self.parse(value) ?? Date() },
            set: { value = Self.display.string(from: $0) }
        )
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(Color(.text).opacity(0.6))
            Spacer()
            if Self.parse(value) != nil {
                DatePicker("", selection: date, displayedComponents: .date)
                    .labelsHidden()
                Button { value = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color(.text).opacity(0.4))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear \(title.lowercased())")
            } else {
                Button("Add date") { value = Self.display.string(from: Date()) }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(.bubbleSelectedBg))
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 44)
        .background(Color(.bubbleBg), in: RoundedRectangle(cornerRadius: 12))
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
