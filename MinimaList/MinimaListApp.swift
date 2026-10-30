import SwiftUI

@main
struct MinimaListApp: App {
    @State private var store = TaskStore()
    @State private var isFloatingWindowShown = true

    var body: some Scene {
        // A single-instance Window, so Show floating window brings back the one widget instead of opening another.
        Window("Minima List", id: "widget") {
            ContentView(store: store, isFloatingWindowShown: isFloatingWindowShown)
                .background(WindowAccessor())
                .onAppear { isFloatingWindowShown = true }
                .onDisappear { isFloatingWindowShown = false }
        }
        // macOS 26 still draws the title-bar background over the content despite titlebarAppearsTransparent; this hides it.
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            // Removes File › New Window, which would otherwise open a second widget on ⌘N; the widget's hint button owns ⌘N.
            CommandGroup(replacing: .newItem) {}
        }

        MenuBarExtra("Minima List", systemImage: "checklist") {
            ContentView(store: store, isFloatingWindowShown: isFloatingWindowShown)
        }
        .menuBarExtraStyle(.window)
    }
}
