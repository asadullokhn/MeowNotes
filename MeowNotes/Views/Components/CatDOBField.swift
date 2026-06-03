import SwiftUI

// Date-of-birth helpers. The backend stores a `dob` (ISO yyyy-MM-dd); the app
// shows a relative age ("3 weeks", "1 year 4 months") derived from it on-device.
enum AgeFormat {
    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(identifier: "UTC")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    // Tolerant parse: accepts "yyyy-MM-dd" or a full ISO-8601 timestamp.
    static func date(fromISO raw: String) -> Date? {
        let trimmed = raw.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }
        if let d = dayFormatter.date(from: String(trimmed.prefix(10))) { return d }
        return ISO8601DateFormatter().date(from: trimmed)
    }

    static func iso(_ date: Date) -> String { dayFormatter.string(from: date) }

    // "3 weeks", "8 months", "1 year 4 months" — how the age reads everywhere.
    static func relative(from dob: Date, to now: Date = Date()) -> String {
        let cal = Calendar.current
        let ym = cal.dateComponents([.year, .month], from: dob, to: now)
        let years = max(0, ym.year ?? 0)
        let months = max(0, ym.month ?? 0)
        func plural(_ n: Int) -> String { n == 1 ? "" : "s" }
        if years >= 1 {
            if months > 0 { return "\(years) year\(plural(years)) \(months) month\(plural(months))" }
            return "\(years) year\(plural(years))"
        }
        if months >= 1 { return "\(months) month\(plural(months))" }
        let days = max(0, cal.dateComponents([.day], from: dob, to: now).day ?? 0)
        let weeks = days / 7
        if weeks >= 1 { return "\(weeks) week\(plural(weeks))" }
        return days <= 1 ? "Newborn" : "\(days) days"
    }

    static func relative(fromISO raw: String) -> String? {
        guard let date = date(fromISO: raw) else { return nil }
        return relative(from: date)
    }
}

// Optional date-of-birth picker. Unset shows a prompt; once set, a compact date
// picker (capped at today) plus the live relative-age caption. Used by New Cat
// and Edit profile so both read age the same way.
struct CatDOBField: View {
    @Binding var dob: Date?

    private static var defaultDOB: Date {
        Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
    }

    private var bound: Binding<Date> {
        Binding(get: { dob ?? Self.defaultDOB }, set: { dob = $0 })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let dob {
                HStack {
                    DatePicker("Date of birth", selection: bound, in: ...Date(), displayedComponents: .date)
                        .labelsHidden()
                    Spacer()
                    Button { self.dob = nil } label: {
                        Text("Clear")
                            .font(.subheadline)
                            .foregroundStyle(Color(.text).opacity(0.5))
                    }
                }
                .padding(.horizontal, 16)
                .frame(height: 52)
                .background(Color(.bubbleBg), in: RoundedRectangle(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color(.bubbleBorder), lineWidth: 1)
                )

                Text("\(AgeFormat.relative(from: dob)) · keeps itself up to date")
                    .font(.caption)
                    .foregroundStyle(Color(.text).opacity(0.5))
            } else {
                Button { dob = Self.defaultDOB } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                        Text("Add date of birth")
                        Spacer()
                    }
                    .font(.system(size: 17))
                    .foregroundStyle(Color(.text).opacity(0.45))
                    .padding(.horizontal, 16)
                    .frame(height: 52)
                    .background(Color(.bubbleBg), in: RoundedRectangle(cornerRadius: 18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color(.bubbleBorder), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
