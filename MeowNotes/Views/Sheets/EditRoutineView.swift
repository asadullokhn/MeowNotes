import SwiftUI

struct EditRoutineView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var auth

    private var catName: String { auth.currentCat?.name ?? "your cat" }

    @State private var routines: [CustomRoutine] = []
    @State private var saving = false
    @State private var saveError: String?

    private var saveErrorBinding: Binding<Bool> {
        Binding(get: { saveError != nil }, set: { if !$0 { saveError = nil } })
    }

    private let textColor = Color("TextColor")
    private let tapToAddBackground = Color(.backgroundPredefined)
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
                Color("AppBg").ignoresSafeArea()

                Form {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What does your cat day look like?")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color("TextColor"))
                        Text("Add the regular things — food, play, litter. Sitters will follow this as today's checklist.")
                            .font(.system(size: 14))
                            .foregroundColor(Color("TextColor"))
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
                            .padding(.vertical, 4)
                        }
                    }
                    .listRowBackground(tapToAddBackground)
                    
                    Section {
                        if routines.isEmpty {
                            // Nothing here based on the prototype
                        } else {
                            ForEach(sortedRoutines) { routine in
                                let routineBinding = binding(for: routine.id)
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(spacing: 10) {
                                        DatePicker("", selection: routineBinding.time, displayedComponents: .hourAndMinute)
                                            .labelsHidden()
                                        
                                        
                                        TextField("Routine", text: routineBinding.title)
                                            .textInputAutocapitalization(.sentences)
                                            .foregroundStyle(Color("TextColor"))
                                            .fontWeight(.semibold)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 9)
                                            .background(Color(.bubbleSectionBg), in: RoundedRectangle(cornerRadius: 12))
                                        
                                        Button {
                                            removeRoutine(id: routine.id)
                                        } label: {
                                            ZStack {
                                                Circle()
                                                    .fill(Color(.backgroundPredefined))
                                                Image(systemName: "xmark")
                                                    .font(.system(size: 16, weight: .bold))
                                                    .foregroundStyle(Color(.xIcon).opacity(0.5))
                                            }
                                            .frame(width: 40, height: 40)
                                        }
                                        .buttonStyle(.plain)
                                        .accessibilityLabel("Remove routine")
                                    }
                                    .padding(.vertical, 6)
                                    
                                    VStack {
                                        TextField("Description", text: routineBinding.details, axis: .vertical)
                                            .lineLimit(2...4)
                                            .textInputAutocapitalization(.sentences)
                                            .foregroundStyle(Color("TextColor"))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 9)
                                            .background(Color(.bubbleSectionBg), in: RoundedRectangle(cornerRadius: 12))
                                    }
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(backgroundFieldColor)
                                    )
                                }
                                .padding(.vertical, 4)
                                
                            }
                        }
                    }
                    .listRowBackground(Color("BubbleBg"))

                    Section {
                        Button {
                            addRoutine()
                        } label: {
                            Text("+ Custom Routine")
                                .foregroundStyle(textColor)
                                .padding(.vertical, 10)
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
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                    .listRowBackground(Color("BubbleBg"))
                }
                .scrollContentBackground(.hidden)
                .safeAreaInset(edge: .bottom) {
                    VStack(spacing: 16) {
                        Rectangle()
                            .fill(Color(.bubbleBorder))
                            .frame(height: 2)
                        
                        HStack {
                            Button {
                                dismiss()
                            } label: {
                                Text("Cancel")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: 100)
                                    .frame(height: 54)
                                    .background(Color(.systemGray5))
                                    .clipShape(RoundedRectangle(cornerRadius: 30))
                            }

                            Button {
                                save()
                            } label: {
                                Group {
                                    if saving { ProgressView().tint(.white) }
                                    else { Text("Save").fontWeight(.semibold) }
                                }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 54)
                                    .background(Color("SaveBg"))
                                    .clipShape(RoundedRectangle(cornerRadius: 30))
                            }
                            .disabled(saving)
                        }
                    }
                    .padding(8)
                    .background(Color("AppBg").ignoresSafeArea(edges: .bottom))
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text(catName.uppercased() + " · ROUTINE")
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
            .onAppear(perform: loadRoutines)
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
