import SwiftUI
import SwiftData

struct PatternView: View {
    @Query private var blocks: [YohakuBlock]
    @State private var displayedMonth = Date()

    private var hasAnyBlockInMonth: Bool {
        DateHelpers.daysOfMonth(containing: displayedMonth).contains { day in
            blocks.contains { DateHelpers.isSameDay($0.date, day) }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("pattern.title")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundStyle(.black)

                    monthSelector

                    PatternGridView(month: displayedMonth) { day in
                        blocks.contains { DateHelpers.isSameDay($0.date, day) }
                    }

                    if !hasAnyBlockInMonth {
                        EmptyStateView(message: "empty.pattern")
                    }
                }
                .padding(24)
            }
            .background(Color.white)
        }
    }

    private var monthSelector: some View {
        HStack(spacing: 16) {
            Button {
                shiftMonth(by: -1)
            } label: {
                Image(systemName: "chevron.backward")
                    .font(.footnote)
                    .foregroundStyle(.gray)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel(Text("accessibility.previous_month"))

            Text(displayedMonth, format: .dateTime.year().month(.wide))
                .font(.subheadline)
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity)

            Button {
                shiftMonth(by: 1)
            } label: {
                Image(systemName: "chevron.forward")
                    .font(.footnote)
                    .foregroundStyle(.gray)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel(Text("accessibility.next_month"))
        }
    }

    private func shiftMonth(by value: Int) {
        if let shifted = Calendar.current.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = shifted
        }
    }
}

#Preview {
    PatternView()
        .modelContainer(for: YohakuBlock.self, inMemory: true)
}
