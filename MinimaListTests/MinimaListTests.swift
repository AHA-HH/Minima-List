import Foundation
import Testing
@testable import MinimaList

@MainActor
struct MinimaListTests {
    @Test func contentViewConstructs() {
        let suite = "test-\(UUID())"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        _ = ContentView(store: TaskStore(defaults: defaults), isFloatingWindowShown: true)
    }
}
