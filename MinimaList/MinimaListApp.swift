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
        .commands {
            // Replaces File › New Window, which would otherwise open a second widget on ⌘N.
            CommandGroup(replacing: .newItem) {
                NewTaskButton()
            }
        }
    }
}

// A view inside the command group can read focused values where the Commands type itself can't always.
private struct NewTaskButton: View {
    @FocusedValue(\.focusComposer) private var focusComposer

    var body: some View {
        Button("New Task") { focusComposer?() }
            .keyboardShortcut("n")
            .disabled(focusComposer == nil)
    }
}
