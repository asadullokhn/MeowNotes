
import SwiftUI

struct EditRoutineView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var routines: [CustomRoutine] = []
    private let textColor = Color(red: 61.0 / 255.0, green: 51.0 / 255.0, blue: 41.0 / 255.0)
    private let tapToAddBackground = Color(red: 243.0 / 255.0, green: 236.0 / 255.0, blue: 226.0 / 255.0)
    private let timeChipColor = Color(red: 167.0 / 255.0, green: 154.0 / 255.0, blue: 137.0 / 255.0)
    private let backgroundFieldColor = Color(red: 240.0 / 255.0, green: 233.0 / 255.0, blue: 219.0 / 255.0)

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

    var body: some View {
        NavigationStack {
            ZStack {
                Color("bg").ignoresSafeArea()

                Form {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What does your cat day look like?")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundStyle(textColor)
                        Text("Add the regular things — food, play, litter. Sitters will follow this as today's checklist.")
                            .font(.subheadline)
                            .foregroundStyle(textColor)
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    
                    Section {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("TAP TO ADD")
                                .font(.headline)
                                .bold()
                                .foregroundStyle(textColor)

                            FlowLayout(spacing: 12) {
                                ForEach(commonRoutines) { routine in
                                    let isAdded = isCommonRoutineAdded(routine)
                                    Button {
                                        addCommonRoutine(routine)
                                    } label: {
                                        HStack(spacing: 8) {
                                            Text(formatTime(routine.time))
                                                .font(.footnote)
                                                .foregroundStyle(timeChipColor)
                                                .padding(.vertical, 2)
                                                .padding(.horizontal, 6)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 6)
                                                        .fill(Color("bg2"))
                                                )
                                            Text(routine.title)
                                                .lineLimit(1)
                                                .foregroundStyle(textColor)
                                        }
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 10)
                                        .background(
                                            Capsule()
                                                .fill(Color("bg2"))
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    .disabled(isAdded)
                                    .opacity(isAdded ? 0.8 : 1)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listRowBackground(tapToAddBackground)
                    
                    Section {
                        if routines.isEmpty {
                            Text("No routines yet")
                                .foregroundStyle(textColor)
                                .opacity(0.6)
                        } else {
                            ForEach(sortedRoutines) { routine in
                                let routineBinding = binding(for: routine.id)
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(spacing: 10) {
                                        DatePicker("", selection: routineBinding.time, displayedComponents: .hourAndMinute)
                                            .labelsHidden()
                                            .tint(textColor)
                                            .padding(.vertical, 6)
                                            .padding(.horizontal, 8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 32)
                                                    .fill(backgroundFieldColor)
                                            )
                                        
                                        TextField("Routine", text: routineBinding.title)
                                            .textInputAutocapitalization(.sentences)
                                            .foregroundStyle(textColor)
                                            .padding(.vertical, 6)
                                            .padding(.horizontal, 8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 32)
                                                    .fill(backgroundFieldColor)
                                            )

                                        Button {
                                            removeRoutine(id: routine.id)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(.secondary)
                                                .padding(.vertical, 6)
                                                .padding(.horizontal, 4)
                                        }
                                        .buttonStyle(.plain)
                                        .accessibilityLabel("Remove routine")
                                    }
                                    .padding(.vertical, 6)
                                    
                                    VStack {
                                        TextField("Description", text: routineBinding.details, axis: .vertical)
                                            .lineLimit(2...4)
                                            .textInputAutocapitalization(.sentences)
                                            .foregroundStyle(textColor)
                                            .padding(8)
                                    }
                                    .background(
                                        RoundedRectangle(cornerRadius: 32)
                                            .fill(backgroundFieldColor)
                                    )
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .listRowBackground(Color("bg2"))

                    Section {
                        Button {
                            addRoutine()
                        } label: {
                            Text("+ Custom Routine")
                                .foregroundStyle(textColor)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 32)
                                        .fill(Color("bg2"))
                                )
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                    .listRowBackground(Color("bg2"))
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Routine")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { dismiss() }
                    }
                }
            }
        }
    }

    private func addRoutine() {
        routines.append(CustomRoutine())
    }

    private func addCommonRoutine(_ routine: CommonRoutine) {
        routines.append(CustomRoutine(time: routine.time, title: routine.title, details: routine.details))
    }

    private func isCommonRoutineAdded(_ routine: CommonRoutine) -> Bool {
        // Compares by title so that if the user manually typed "Breakfast", it would also disable the button
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

#Preview { EditRoutineView() }
