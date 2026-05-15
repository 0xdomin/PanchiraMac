import SwiftUI

@main
struct PanchiraMacApp: App {
    @State private var state = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(state)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 700, height: 820)
    }
}
