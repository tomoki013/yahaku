import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("tab.today", systemImage: "circle")
                }
            WeekView()
                .tabItem {
                    Label("tab.week", systemImage: "rectangle.split.3x1")
                }
            PatternView()
                .tabItem {
                    Label("tab.pattern", systemImage: "square.grid.3x3")
                }
        }
        .tint(.black)
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: YohakuBlock.self, inMemory: true)
}
