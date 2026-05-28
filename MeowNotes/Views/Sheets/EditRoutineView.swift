// Owner: TBD (claim by editing this line)
//
// Modal editor for the cat's daily Routine (feeding times, etc.).
// Presented from HomeView. Replace the placeholder body.

import SwiftUI

struct EditRoutineView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var items: [RoutineItem] = [
        RoutineItem(title: "Breakfast", time: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date(), isEnabled: true),
        RoutineItem(title: "Dinner", time: Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date(), isEnabled: true)
    ]
    @State private var newTitle = ""
    @State private var newTime = Date()

    @State private var quietHoursEnabled = false
    @State private var quietStart = Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var quietEnd = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date()

    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Schedule") {
                    ForEach($items) { $item in
                        HStack {
                            Toggle(isOn: $item.isEnabled) {
                                TextField("Title", text: $item.title)
                            }
                            DatePicker("", selection: $item.time, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }
                    }
                    .onDelete(perform: deleteItem)
                }

                Section("Add Item") {
                    TextField("Title", text: $newTitle)
                    DatePicker("Time", selection: $newTime, displayedComponents: .hourAndMinute)
                    Button("Add") { addItem() }
                        .disabled(newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                Section("Quiet Hours") {
                    Toggle("Enable quiet hours", isOn: $quietHoursEnabled)
                    if quietHoursEnabled {
                        DatePicker("From", selection: $quietStart, displayedComponents: .hourAndMinute)
                        DatePicker("To", selection: $quietEnd, displayedComponents: .hourAndMinute)
                    }
                }

                Section("Notes") {
                    TextField("Anything special today", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
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

    private func addItem() {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        items.append(RoutineItem(title: trimmed, time: newTime, isEnabled: true))
        newTitle = ""
        newTime = Date()
    }

    private func deleteItem(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
}

private struct RoutineItem: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var time: Date
    var isEnabled: Bool
}

#Preview { EditRoutineView() }
