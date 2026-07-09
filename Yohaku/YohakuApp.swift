import SwiftUI
import SwiftData

@main
struct YohakuApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(for: YohakuBlock.self)
    }
}
