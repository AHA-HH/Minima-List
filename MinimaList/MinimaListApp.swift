import SwiftUI

@main
struct MinimaListApp: App {
    @State private var store = TaskStore()

    var body: some Scene {
        WindowGroup {
            ContentView(store: store).background(WindowAccessor())
        }
        .windowResizability(.contentSize)
    }
}
