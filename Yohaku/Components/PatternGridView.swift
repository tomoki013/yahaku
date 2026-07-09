import SwiftUI

struct PatternGridView: View {
    let month: Date
    let hasYohaku: (Date) -> Bool

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 7)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(0..<DateHelpers.leadingEmptyCount(forMonthContaining: month), id: \.self) { _ in
                Color.clear
                    .aspectRatio(1, contentMode: .fit)
            }
            ForEach(DateHelpers.daysOfMonth(containing: month), id: \.self) { day in
                cell(for: day)
            }
        }
    }

    @ViewBuilder
    private func cell(for day: Date) -> some View {
        let filled = hasYohaku(day)
        RoundedRectangle(cornerRadius: 3)
            .fill(filled ? Color.black : Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color(white: 0.88), lineWidth: 1)
            )
            .aspectRatio(1, contentMode: .fit)
            .accessibilityElement()
            .accessibilityLabel(
                filled
                    ? Text("accessibility.day_has_yohaku \(day, format: .dateTime.month().day())")
                    : Text("accessibility.day_no_yohaku \(day, format: .dateTime.month().day())")
            )
    }
}
