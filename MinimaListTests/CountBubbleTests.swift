import Testing
@testable import MinimaList

@MainActor
struct CountBubbleTests {
    @Test func noOpenTasksShowsACheckMark() {
        #expect(CountBubble.countText(openCount: 0) == nil)
    }

    @Test func openTasksShowTheirCount() {
        #expect(CountBubble.countText(openCount: 1) == "1")
        #expect(CountBubble.countText(openCount: 12) == "12")
    }

    @Test func accessibilityLabelNamesTheCount() {
        #expect(CountBubble.accessibilityLabel(openCount: 0) == "No open tasks")
        #expect(CountBubble.accessibilityLabel(openCount: 1) == "1 open task")
        #expect(CountBubble.accessibilityLabel(openCount: 3) == "3 open tasks")
    }
}
