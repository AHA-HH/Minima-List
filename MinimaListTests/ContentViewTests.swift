import Testing
@testable import MinimaList

@MainActor
struct ContentViewTests {
    let tasks = [
        TaskItem(title: "A", category: .focus),
        TaskItem(title: "B", category: .life, isComplete: true),
        TaskItem(title: "C", category: .later),
        TaskItem(title: "D", category: .focus, isComplete: true),
    ]

    @Test func showingCompletedKeepsEveryTaskInOrder() {
        #expect(ContentView.visibleTasks(tasks, hidingCompleted: false) == tasks)
    }

    @Test func hidingCompletedKeepsOpenTasksInOrder() {
        #expect(ContentView.visibleTasks(tasks, hidingCompleted: true).map(\.title) == ["A", "C"])
    }

    @Test func hidingWhenAllCompleteIsEmpty() {
        let done = tasks.map { task in
            var task = task
            task.isComplete = true
            return task
        }
        #expect(ContentView.visibleTasks(done, hidingCompleted: true).isEmpty)
    }

    @Test func progressLabelCountsDoneOfTotal() {
        #expect(ContentView.progressLabel(completed: 2, total: 5) == "2 of 5 done")
        #expect(ContentView.progressLabel(completed: 0, total: 0) == "0 of 0 done")
    }

    @Test(arguments: [false, true])
    func noTasksIsEmpty(hidingCompleted: Bool) {
        #expect(ContentView.visibleTasks([], hidingCompleted: hidingCompleted).isEmpty)
    }
}
