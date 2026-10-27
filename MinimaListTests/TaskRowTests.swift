import SwiftUI
import Testing
@testable import MinimaList

@MainActor
struct TaskRowTests {
    @Test func toggleLabelNamesTitleAndState() {
        var task = TaskItem(title: "Reply to email", category: .focus)
        #expect(TaskRow.toggleLabel(for: task) == "Mark Reply to email complete")
        task.isComplete = true
        #expect(TaskRow.toggleLabel(for: task) == "Mark Reply to email incomplete")
    }

    @Test func deleteLabelNamesTitle() {
        let task = TaskItem(title: "Reply to email", category: .focus)
        #expect(TaskRow.deleteLabel(for: task) == "Delete Reply to email")
    }

    @Test(arguments: [false, true])
    func bodyEvaluates(isComplete: Bool) {
        let task = TaskItem(title: "Reply to email", category: .life, isComplete: isComplete)
        _ = TaskRow(task: task, onToggle: {}, onDelete: {}).body
    }
}
