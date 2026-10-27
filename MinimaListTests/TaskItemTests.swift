import AppKit
import Foundation
import Testing
@testable import MinimaList

struct TaskItemTests {
    @Test(arguments: TaskCategory.allCases, [false, true])
    func codableRoundTrip(category: TaskCategory, isComplete: Bool) throws {
        let item = TaskItem(title: "Reply to that email", category: category, isComplete: isComplete)
        let decoded = try JSONDecoder().decode(TaskItem.self, from: JSONEncoder().encode(item))
        #expect(decoded == item)
    }

    @Test func newTaskDefaults() {
        let a = TaskItem(title: "A", category: .focus)
        let b = TaskItem(title: "B", category: .focus)
        #expect(a.isComplete == false)
        #expect(a.id != b.id)
    }

    @Test func rawValuesAreStable() {
        #expect(TaskCategory.allCases.map(\.rawValue) == ["focus", "life", "later"])
    }

    @Test(arguments: TaskCategory.allCases)
    func categoryHasLabelAndRealSymbol(category: TaskCategory) {
        #expect(!category.label.isEmpty)
        #expect(NSImage(systemSymbolName: category.symbol, accessibilityDescription: nil) != nil)
    }

    @Test func unknownCategoryThrows() throws {
        // Start from a real encoding so only the category value is wrong.
        let encoded = try JSONEncoder().encode(TaskItem(title: "x", category: .focus))
        let json = String(decoding: encoded, as: UTF8.self)
        #expect(json.contains("\"focus\""))
        let bad = Data(json.replacingOccurrences(of: "\"focus\"", with: "\"someday\"").utf8)
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(TaskItem.self, from: bad)
        }
    }
}
