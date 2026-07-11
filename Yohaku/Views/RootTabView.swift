import SwiftUI

struct RootTabView: View {
    private enum Tab: Hashable {
        case today
        case week
        case pattern
    }

    @State private var selection: Tab = .today
    @State private var displayedDay = Date()

    // 今日タブを再タップしたら今日に戻る
    private var tabSelection: Binding<Tab> {
        Binding(
            get: { selection },
            set: { newValue in
                if newValue == .today && selection == .today {
                    displayedDay = Date()
                }
                selection = newValue
            }
        )
    }

    var body: some View {
        TabView(selection: tabSelection) {
            TodayView(displayedDay: $displayedDay)
                .tabItem {
                    Label("tab.today", systemImage: "circle")
                }
                .tag(Tab.today)
            WeekView { day in
                displayedDay = day
                selection = .today
            }
            .tabItem {
                Label("tab.week", systemImage: "rectangle.split.3x1")
            }
            .tag(Tab.week)
            PatternView()
                .tabItem {
                    Label("tab.pattern", systemImage: "square.grid.3x3")
                }
                .tag(Tab.pattern)
        }
        .tint(.primary)
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: YohakuBlock.self, inMemory: true)
}
