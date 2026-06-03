import SwiftUI

// Age unit shared by the age picker. Top-level so both the New Cat and Edit
// Profile screens (and the picker itself) refer to the same type.
enum CatAgeUnit: String, CaseIterable, Identifiable {
    case weeks, months, years
    var id: String { rawValue }
    var label: String {
        switch self {
        case .weeks: return "Weeks"
        case .months: return "Months"
        case .years: return "Years"
        }
    }
    var singular: String {
        switch self {
        case .weeks: return "week"
        case .months: return "month"
        case .years: return "year"
        }
    }
}

// The age picker: a number wheel whose range adapts to the chosen unit (so
// "53 weeks" isn't offerable), plus a unit wheel. The first row is "—" so a cat
// with no age reads as unset. A live "born around …" line surfaces the hidden
// birth date the backend anchors to. Shared by New Cat and Edit Profile.
struct CatAgeField: View {
    @Binding var value: String       // "" = unset, otherwise the number as a string
    @Binding var unit: CatAgeUnit
    // Caption shown when no age is set; callers can pass context (e.g. the
    // existing stored age). Defaults to the generic prompt.
    var unsetCaption: String = "Set it once — their age keeps itself up to date."

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 0) {
                Picker("Age value", selection: numberSelection) {
                    ForEach(numberOptions, id: \.self) { n in
                        Text(n == 0 ? "—" : "\(n)").tag(n)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                .clipped()

                Picker("Age unit", selection: $unit) {
                    ForEach(CatAgeUnit.allCases) { unit in
                        Text(unit.label).tag(unit)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                .clipped()
            }
            .frame(height: 130)
            .padding(.horizontal, 8)
            .background(Color(.bubbleBg), in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.bubbleBorder), lineWidth: 1)
            )
            .onChange(of: unit) { _, _ in clampToUnit() }

            Text(captionText)
                .font(.caption)
                .foregroundStyle(Color(.text).opacity(0.5))
        }
    }

    // Sensible upper bound per unit so the wheel rolls into the next unit instead
    // of offering nonsense like "40 months". 0 is the leading "—" (unset) row.
    private var numberOptions: [Int] {
        let upper: Int
        switch unit {
        case .weeks: upper = 51
        case .months: upper = 23
        case .years: upper = 30
        }
        return [0] + Array(1...upper)
    }

    // Bridges the Int-based wheel to the String `value`; 0 means "unset".
    private var numberSelection: Binding<Int> {
        Binding(
            get: { Int(value.trimmingCharacters(in: .whitespaces)) ?? 0 },
            set: { value = $0 == 0 ? "" : String($0) }
        )
    }

    // After a unit switch, pull a now-out-of-range number back in.
    private func clampToUnit() {
        guard let n = Int(value.trimmingCharacters(in: .whitespaces)), n > 0,
              let maxN = numberOptions.last, n > maxN else { return }
        value = String(maxN)
    }

    private var captionText: String {
        if let born = bornAroundText { return "\(born) · keeps itself up to date" }
        return unsetCaption
    }

    // The approximate birth date the backend will anchor to, shown so the
    // auto-advancing age is transparent rather than surprising.
    private var bornAroundText: String? {
        guard let v = Int(value.trimmingCharacters(in: .whitespaces)), v > 0 else { return nil }
        var comp = DateComponents()
        switch unit {
        case .weeks: comp.day = -v * 7
        case .months: comp.month = -v
        case .years: comp.year = -v
        }
        guard let date = Calendar.current.date(byAdding: comp, to: Date()) else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return "Born around \(formatter.string(from: date))"
    }
}

extension CatAgeField {
    // Build the "8 months" / "2 years" string the backend parses, or nil when
    // there's nothing valid to send.
    static func compose(value: String, unit: CatAgeUnit) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        guard let v = Int(trimmed), v > 0 else { return nil }
        let u = v == 1 ? unit.singular : unit.label.lowercased()
        return "\(v) \(u)"
    }

    // Split a stored age string ("8 months", "2 years", legacy "3") back into the
    // picker's value + unit. Days or unparseable text return a blank value.
    static func parse(_ raw: String) -> (String, CatAgeUnit) {
        let lower = raw.lowercased()
        let fromFirstDigit = lower.drop(while: { !$0.isNumber })
        let number = fromFirstDigit.prefix(while: { $0.isNumber })
        guard !number.isEmpty else { return ("", .months) }
        let afterNumber = fromFirstDigit.drop(while: { $0.isNumber || $0 == "." })
        switch afterNumber.first(where: { $0.isLetter }) {
        case .some("w"): return (String(number), .weeks)
        case .some("m"): return (String(number), .months)
        case .some("y"), .none: return (String(number), .years)   // bare number = years
        default: return ("", .months)                             // days / unknown unit
        }
    }
}
