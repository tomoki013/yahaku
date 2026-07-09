import SwiftUI
import SwiftData

struct AddYohakuView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var date = Date()
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600)

    private var canPlace: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && startTime < endTime
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("field.name", text: $title)
                }
                Section {
                    DatePicker("field.date", selection: $date, displayedComponents: .date)
                    DatePicker("field.start", selection: $startTime, displayedComponents: .hourAndMinute)
                    DatePicker("field.end", selection: $endTime, displayedComponents: .hourAndMinute)
                }
                Section {
                    Button("action.place") {
                        place()
                    }
                    .disabled(!canPlace)
                    .frame(maxWidth: .infinity)
                    .fontWeight(.medium)
                    .foregroundStyle(canPlace ? .black : .gray)
                }
            }
            .navigationTitle("add.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.black)
                    }
                    .accessibilityLabel(Text("action.close"))
                }
            }
        }
        .tint(.black)
    }

    private func place() {
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: date)

        func onSelectedDay(_ time: Date) -> Date {
            let components = calendar.dateComponents([.hour, .minute], from: time)
            return calendar.date(
                bySettingHour: components.hour ?? 0,
                minute: components.minute ?? 0,
                second: 0,
                of: day
            ) ?? day
        }

        let block = YohakuBlock(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            date: day,
            startTime: onSelectedDay(startTime),
            endTime: onSelectedDay(endTime)
        )
        modelContext.insert(block)
        dismiss()
    }
}

#Preview {
    AddYohakuView()
        .modelContainer(for: YohakuBlock.self, inMemory: true)
}
