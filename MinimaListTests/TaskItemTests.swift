import AppKit
import Foundation
import Testing
@testable import MinimaList

struct TaskItemTests {
    @Test(arguments: Category.allCases, [false, true])
    func codableRoundTrip(category: MinimaList.Category, isComplete: Bool) throws {
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
        #expect(Category.allCases.map(\.rawValue) == ["focus", "life", "later"])
    }

    @Test(arguments: Category.allCases)
    func categoryHasLabelAndRealSymbol(category: MinimaList.Category) {
        #expect(!category.label.isEmpty)
        #expect(NSImage(systemSymbolName: category.symbol, accessibilityDescription: nil) != nil)
    }

    @Test func unknownCategoryThrows() {
        let json = Data("""
        {"id":"\(UUID().uuidString)","title":"x","category":"someday","isComplete":false,"createdAt":0}
        """.utf8)
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(TaskItem.self, from: json)
        }
    }
}
