import SwiftUI
import SwiftData

struct WeekView: View {
    @Query(sort: \YohakuBlock.startTime) private var blocks: [YohakuBlock]
    @State private var isAdding = false

    private var weekDays: [Date] {
        DateHelpers.daysOfWeek(containing: Date())
    }

    private var hasAnyBlockThisWeek: Bool {
        weekDays.contains { day in
            blocks.contains { DateHelpers.isSameDay($0.date, day) }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("tab.week")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundStyle(.black)

                    if hasAnyBlockThisWeek {
                        VStack(spacing: 0) {
                            ForEach(weekDays, id: \.self) { day in
                                dayRow(day)
                                if day != weekDays.last {
                                    Divider()
                                        .overlay(Color(white: 0.92))
                                }
                            }
                        }
                    } else {
                        EmptyStateView(message: "empty.week")
                    }
                }
                .padding(24)
            }
            .background(Color.white)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isAdding = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(.black)
                    }
                    .accessibilityLabel(Text("add.title"))
                }
            }
            .sheet(isPresented: $isAdding) {
                AddYohakuView()
            }
        }
    }

    private func dayRow(_ day: Date) -> some View {
        let dayBlocks = blocks.filter { DateHelpers.isSameDay($0.date, day) }
        let isToday = DateHelpers.isSameDay(day, Date())

        return HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text(day, format: .dateTime.weekday(.abbreviated))
                    .font(.caption)
                    .foregroundStyle(isToday ? .black : .gray)
                Text(day, format: .dateTime.day())
                    .font(.subheadline)
                    .fontWeight(isToday ? .semibold : .regular)
                    .foregroundStyle(isToday ? .black : .gray)
            }
            .frame(minWidth: 44, alignment: .leading)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(dayBlocks) { block in
                    HStack(spacing: 8) {
                        Capsule()
                            .fill(Color.black)
                            .frame(width: 24, height: 4)
                        Text(block.title)
                            .font(.footnote)
                            .foregroundStyle(.black)
                        Text(block.startTime, format: .dateTime.hour().minute())
                            .font(.caption2)
                            .foregroundStyle(.gray)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 12)
    }
}

#Preview {
    WeekView()
        .modelContainer(for: YohakuBlock.self, inMemory: true)
}
