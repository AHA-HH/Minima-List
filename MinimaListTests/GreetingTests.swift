import Foundation
import Testing
@testable import MinimaList

struct GreetingTests {
    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()

    private static func date(hour: Int, minute: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 10, day: 26, hour: hour, minute: minute))!
    }

    @Test(arguments: [
        (5, 0, "Good morning"),
        (11, 59, "Good morning"),
        (12, 0, "Good afternoon"),
        (17, 59, "Good afternoon"),
        (18, 0, "Good evening"),
        (23, 59, "Good evening"),
        (0, 0, "Good evening"),
        (4, 59, "Good evening"),
    ])
    func greetingMatchesTimeOfDay(hour: Int, minute: Int, expected: String) {
        #expect(greeting(for: Self.date(hour: hour, minute: minute), calendar: Self.calendar) == expected)
    }
}
