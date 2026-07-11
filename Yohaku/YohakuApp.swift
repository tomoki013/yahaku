import SwiftUI
import SwiftData

@main
struct YohakuApp: App {
    @AppStorage("appearanceMode") private var appearanceMode = AppearanceMode.system.rawValue

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .background(
                    AppearanceApplier(
                        mode: AppearanceMode(rawValue: appearanceMode) ?? .system
                    )
                )
        }
        .modelContainer(for: YohakuBlock.self)
    }
}
