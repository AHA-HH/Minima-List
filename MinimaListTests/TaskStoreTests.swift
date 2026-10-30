import Foundation
import Testing
@testable import MinimaList

@MainActor
struct TaskStoreTests {
    /// Runs `body` with a fresh suite, then removes it (tests run in parallel).
    private func withDefaults(_ body: (UserDefaults) throws -> Void) rethrows {
        let suite = "test-\(UUID())"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        try body(defaults)
    }

    @Test func addTrimsAndIgnoresBlank() {
        withDefaults { defaults in
            let store = TaskStore(defaults: defaults)
            store.add(title: "   ", category: .focus)
            store.add(title: "", category: .focus)
            store.add(title: "\n\t ", category: .focus)
            #expect(store.tasks.isEmpty)
            #expect(defaults.data(forKey: "tasks") == nil)
            store.add(title: "  \n Reply to email \t\n", category: .life)
            #expect(store.tasks.map(\.title) == ["Reply to email"])
            #expect(store.tasks.first?.category == .life)
        }
    }

    @Test func addInsertsAtTop() {
        withDefaults { defaults in
            let store = TaskStore(defaults: defaults)
            store.add(title: "a", category: .focus)
            store.add(title: "b", category: .focus)
            #expect(store.tasks.map(\.title) == ["b", "a"])
        }
    }

    @Test func toggleFlipsAndIgnoresUnknownId() throws {
        try withDefaults { defaults in
            let store = TaskStore(defaults: defaults)
            store.add(title: "a", category: .focus)
            let id = try #require(store.tasks.first?.id)
            store.toggle(id)
            #expect(store.tasks.first?.isComplete == true)
            store.toggle(id)
            #expect(store.tasks.first?.isComplete == false)
            let before = store.tasks
            store.toggle(UUID())
            #expect(store.tasks == before)
        }
    }

    @Test func removeDeletesOnlyTarget() {
        withDefaults { defaults in
            let store = TaskStore(defaults: defaults)
            for title in ["a", "b", "c"] { store.add(title: title, category: .focus) }
            store.remove(store.tasks[1].id)
            #expect(store.tasks.map(\.title) == ["c", "a"])
            store.remove(UUID())
            #expect(store.tasks.map(\.title) == ["c", "a"])
        }
    }

    @Test func clearCompletedKeepsOrderOfRest() {
        withDefaults { defaults in
            let store = TaskStore(defaults: defaults)
            for title in ["a", "b", "c", "d"] { store.add(title: title, category: .focus) }
            // tasks: d, c, b, a; complete c and a.
            store.toggle(store.tasks[1].id)
            store.toggle(store.tasks[3].id)
            store.clearCompleted()
            #expect(store.tasks.map(\.title) == ["d", "b"])
            #expect(store.tasks.allSatisfy { !$0.isComplete })
        }
    }

    @Test func progressAndCompletedCount() {
        withDefaults { defaults in
            let store = TaskStore(defaults: defaults)
            #expect(store.progress == 0)
            #expect(store.completedCount == 0)
            #expect(store.openCount == 0)
            store.add(title: "a", category: .focus)
            store.add(title: "b", category: .focus)
            store.toggle(store.tasks[0].id)
            #expect(store.progress == 0.5)
            #expect(store.completedCount == 1)
            #expect(store.openCount == 1)
            store.toggle(store.tasks[1].id)
            #expect(store.progress == 1)
            #expect(store.completedCount == 2)
            #expect(store.openCount == 0)
        }
    }

    @Test func persistenceRoundTrip() {
        withDefaults { defaults in
            let store = TaskStore(defaults: defaults, key: "round")
            store.add(title: "a", category: .focus)
            store.add(title: "b", category: .life)
            store.add(title: "c", category: .later)
            store.toggle(store.tasks[1].id)
            let reloaded = TaskStore(defaults: defaults, key: "round")
            #expect(reloaded.tasks == store.tasks)
            #expect(reloaded.tasks.count == 3)
        }
    }

    @Test func everyMutationPersists() {
        withDefaults { defaults in
            let store = TaskStore(defaults: defaults)
            @MainActor func fresh() -> [TaskItem] { TaskStore(defaults: defaults).tasks }

            store.add(title: "a", category: .focus)
            store.add(title: "b", category: .focus)
            #expect(fresh() == store.tasks)

            store.toggle(store.tasks[0].id)
            #expect(fresh().first?.isComplete == true)

            store.remove(store.tasks[1].id)
            #expect(fresh().map(\.title) == ["b"])

            store.clearCompleted()
            #expect(fresh().isEmpty)
        }
    }

    @Test func corruptDataIsKeptAndLoadsEmpty() {
        withDefaults { defaults in
            let bad = Data("not json".utf8)
            defaults.set(bad, forKey: "tasks")
            let store = TaskStore(defaults: defaults)
            #expect(store.tasks.isEmpty)
            #expect(defaults.data(forKey: "tasks.corrupt") == bad)
        }
    }
}
