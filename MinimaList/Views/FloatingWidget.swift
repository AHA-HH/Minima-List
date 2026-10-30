import SwiftUI

/// The floating window's content: the full widget, or the count bubble while collapsed (design §8.7, §11).
struct FloatingWidget: View {
    let store: TaskStore
    let isFloatingWindowShown: Bool

    // Session state (§10): never persisted, so every launch starts expanded.
    @State private var isCollapsed = false

    var body: some View {
        if isCollapsed {
            CountBubble(openCount: store.openCount) { isCollapsed = false }
        } else {
            ContentView(store: store, isFloatingWindowShown: isFloatingWindowShown) { isCollapsed = true }
        }
    }
}
