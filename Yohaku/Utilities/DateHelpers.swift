import Foundation

enum DateHelpers {
    static var calendar: Calendar { Calendar.current }

    static func isSameDay(_ a: Date, _ b: Date) -> Bool {
        calendar.isDate(a, inSameDayAs: b)
    }

    /// The seven days of the week containing `date`, ordered by the user's locale.
    static func daysOfWeek(containing date: Date) -> [Date] {
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: date) else {
            return []
        }
        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: interval.start)
        }
    }

    /// All days of the month containing `date`.
    static func daysOfMonth(containing date: Date) -> [Date] {
        guard let interval = calendar.dateInterval(of: .month, for: date),
              let dayCount = calendar.range(of: .day, in: .month, for: date)?.count else {
            return []
        }
        return (0..<dayCount).compactMap {
            calendar.date(byAdding: .day, value: $0, to: interval.start)
        }
    }

    /// Leading offset (0-6) of the month's first day within a locale-ordered week row.
    static func leadingEmptyCount(forMonthContaining date: Date) -> Int {
        guard let interval = calendar.dateInterval(of: .month, for: date) else { return 0 }
        let weekday = calendar.component(.weekday, from: interval.start)
        return (weekday - calendar.firstWeekday + 7) % 7
    }
}
