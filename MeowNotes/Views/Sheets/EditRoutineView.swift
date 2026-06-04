import SwiftUI

struct EditRoutineView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var auth

    private var catName: String { auth.currentCat?.name ?? "your cat" }

    @State private var routines: [CustomRoutine] = []
    @State private var saving = false
    @State private var saveError: String?
    @State private var initialSignature: [String] = []
    @State private var loaded = false

    private var saveErrorBinding: Binding<Bool> {
        Binding(get: { saveError != nil }, set: { if !$0 { saveError = nil } })
    }

    private let textColor = Color("TextColor")
    private let timeChipColor = Color(red: 167.0 / 255.0, green: 154.0 / 255.0, blue: 137.0 / 255.0)

    private let commonRoutines: [CommonRoutine] = [
        CommonRoutine(title: "Breakfast", time: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date(), details: "Serve morning meal and refresh water."),
        CommonRoutine(title: "Dinner", time: Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date(), details: "Evening meal and bowl rinse."),
        CommonRoutine(title: "Brushing", time: Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date(), details: "Quick brush session to reduce shedding."),
        CommonRoutine(title: "Medication", time: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date(), details: "Administer prescribed meds if needed."),
        CommonRoutine(title: "Playtime", time: Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date()) ?? Date(), details: "10-15 minutes of interactive play.")
    ]

    private var sortedRoutines: [CustomRoutine] {
        routines.sorted { $0.time < $1.time }
    }

    private var hasChanges: Bool { routineSignature(routines) != initialSignature }

    // Compares routines ignoring transient ids — what actually gets saved.
    private func routineSignature(_ list: [CustomRoutine]) -> [String] {
        list.sorted { $0.time < $1.time }
            .filter { !$0.title.trimmingCharacters(in: .whitespaces).isEmpty }
            .map { "\(formatTime($0.time))|\($0.title.trimmingCharacters(in: .whitespaces))|\($0.details.trimmingCharacters(in: .whitespaces))" }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    // MARK: Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What does your cat's day look like?")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundStyle(Color("TextColor"))
                            .accessibilityAddTraits(.isHeader)
                        Text("Add the regular things — food, play, litter. Sitters will follow this as today's checklist.")
                            .font(.subheadline)
                            .foregroundStyle(Color("TextColor"))
                    }

                    // MARK: Tap to add (Raffi's chip design)
                    VStack(alignment: .leading, spacing: 14) {
                        SectionLabel("Tap to add")
                        FlowLayout(spacing: 12) {
                            ForEach(commonRoutines) { routine in
                                let isAdded = isCommonRoutineAdded(routine)
                                Button {
                                    addCommonRoutine(routine)
                                } label: {
                                    HStack(spacing: 8) {
                                        // Follow the device's 12h/24h setting, like the DatePicker rows below.
                                        Text(routine.time, style: .time)
                                            .font(.footnote)
                                            .foregroundStyle(timeChipColor)
                                            .padding(.vertical, 2)
                                            .padding(.horizontal, 6)
                                            .background(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(Color("BubbleBg"))
                                            )
                                        Text(routine.title)
                                            .lineLimit(1)
                                            .foregroundStyle(textColor)
                                    }
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 10)
                                    .background(
                                        Capsule()
                                            .fill(Color("BubbleBg"))
                                    )
                                }
                                .buttonStyle(.plain)
                                .disabled(isAdded)
                                .opacity(isAdded ? 0.8 : 1)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 32)
                                        .stroke(textColor.opacity(0.1), lineWidth: 2)
                                )
                            }
                        }
                    }

                    // MARK: Routine rows
                    if !routines.isEmpty {
                        VStack(spacing: 12) {
                            ForEach(sortedRoutines) { routine in
                                let routineBinding = binding(for: routine.id)
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(spacing: 10) {
                                        DatePicker("", selection: routineBinding.time, displayedComponents: .hourAndMinute)
                                            .labelsHidden()

                                        CareTextField(placeholder: "Routine", text: routineBinding.title, bold: true)

                                        RemoveCircleButton(size: 40) {
                                            removeRoutine(id: routine.id)
                                        }
                                    }

                                    CareTextField(placeholder: "Description", text: routineBinding.details, axis: .vertical, limit: 280)
                                }
                                .padding(14)
                                .background(Color("BubbleBg"), in: RoundedRectangle(cornerRadius: 20))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color("BubbleBorder"), lineWidth: 1)
                                )
                                .accessibilityAction(named: "Delete routine") {
                                    removeRoutine(id: routine.id)
                                }
                            }
                        }
                    }

                    // MARK: Add custom routine
                    Button {
                        addRoutine()
                    } label: {
                        Text("+ Custom Routine")
                            .foregroundStyle(textColor)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("BubbleBg"))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(textColor.opacity(0.1), lineWidth: 2)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color("AppBg"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color(.text))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    SaveToolbarButton(saving: saving, hasChanges: hasChanges, action: save)
                }
            }
            .onAppear {
                loadRoutines()
                if !loaded { initialSignature = routineSignature(routines); loaded = true }
            }
            .alert("Couldn't save", isPresented: saveErrorBinding) {
                Button("OK", role: .cancel) {}
            } message: { Text(saveError ?? "") }
        }
    }

    private func loadRoutines() {
        guard routines.isEmpty, let items = auth.currentCat?.feedingRoutine, !items.isEmpty else { return }
        routines = items.map {
            CustomRoutine(time: parseTime($0.time), title: $0.title, details: $0.detail)
        }
    }

    private func parseTime(_ string: String) -> Date {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "h:mm a"
        return f.date(from: string) ?? Date()
    }

    private func save() {
        guard !saving, let catID = auth.currentCat?.id else { return }
        saving = true
        saveError = nil
        let items = sortedRoutines
            .filter { !$0.title.trimmingCharacters(in: .whitespaces).isEmpty }
            .map {
                RoutineItem(time: formatTime($0.time),
                            title: $0.title.trimmingCharacters(in: .whitespaces),
                            detail: $0.details.trimmingCharacters(in: .whitespaces))
            }
        Task {
            do {
                try await auth.updateRoutine(catID: catID, items)
                dismiss()
            } catch {
                saveError = error.localizedDescription
            }
            saving = false
        }
    }

    private func addRoutine() {
        routines.append(CustomRoutine())
    }

    private func addCommonRoutine(_ routine: CommonRoutine) {
        routines.append(CustomRoutine(time: routine.time, title: routine.title, details: routine.details))
    }

    private func isCommonRoutineAdded(_ routine: CommonRoutine) -> Bool {
        let trimmedTitle = routine.title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return routines.contains {
            $0.title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == trimmedTitle
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    private func removeRoutine(id: UUID) {
        routines.removeAll { $0.id == id }
    }

    private func binding(for id: UUID) -> Binding<CustomRoutine> {
        Binding(
            get: {
                routines.first { $0.id == id } ?? CustomRoutine()
            },
            set: { updated in
                if let index = routines.firstIndex(where: { $0.id == id }) {
                    routines[index] = updated
                }
            }
        )
    }
}

private struct CustomRoutine: Identifiable, Hashable {
    let id = UUID()
    var time: Date = Date()
    var title: String = ""
    var details: String = ""
}

private struct CommonRoutine: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let time: Date
    let details: String
}

#Preview {
    EditRoutineView()
        .environment(AuthManager())
}
