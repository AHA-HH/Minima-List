import SwiftUI

@main
struct MinimaListApp: App {
    @State private var store = TaskStore()

    var body: some Scene {
        WindowGroup {
            ContentView(store: store).background(WindowAccessor())
        }
        // macOS 26 still draws the title-bar background over the content despite titlebarAppearsTransparent; this hides it.
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
