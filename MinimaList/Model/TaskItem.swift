import Foundation
import struct SwiftUI.Color

struct TaskItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var category: TaskCategory
    var isComplete: Bool
    var createdAt: Date

    init(id: UUID = UUID(), title: String, category: TaskCategory, isComplete: Bool = false, createdAt: Date = .now) {
        self.id = id
        self.title = title
        self.category = category
        self.isComplete = isComplete
        self.createdAt = createdAt
    }
}

/// Raw values are persisted; never rename them.
enum TaskCategory: String, Codable, CaseIterable {
    case focus, life, later

    var label: String {
        switch self {
        case .focus: "Focus"
        case .life: "Life"
        case .later: "Later"
        }
    }

    var color: Color {
        switch self {
        case .focus: Color(red: 1.00, green: 0.48, blue: 0.40)
        case .life: Color(red: 0.45, green: 0.66, blue: 1.00)
        case .later: Color(red: 0.66, green: 0.55, blue: 0.90)
        }
    }

    /// SF Symbol name.
    var symbol: String {
        switch self {
        case .focus: "scope"
        case .life: "leaf"
        case .later: "tray"
        }
    }
}
