import SwiftUI

/// The non-category color tokens (design §9).
extension Color {
    static let widgetBackground = Color(red: 0.11, green: 0.10, blue: 0.13)
    static let surfaceRaised = Color.white.opacity(0.06)
    static let textPrimary = Color.white.opacity(0.92)
    static let textSecondary = Color.white.opacity(0.55)
    static let accentCoral = TaskCategory.focus.color
}
