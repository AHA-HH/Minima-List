import SwiftUI
import Testing
@testable import MinimaList

@MainActor
struct CategorySelectorTests {
    @Test(arguments: TaskCategory.allCases)
    func bodyEvaluates(selection: TaskCategory) {
        _ = CategorySelector(selection: .constant(selection)).body
    }

    @Test func categoriesAreInSelectorOrder() {
        #expect(TaskCategory.allCases == [.focus, .life, .later])
    }
}
