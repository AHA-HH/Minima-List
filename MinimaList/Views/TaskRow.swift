import SwiftUI

struct TaskRow: View {
    let task: TaskItem
    let onToggle: () -> Void
    let onDelete: () -> Void

    @State private var isHovered = false

    static func toggleLabel(for task: TaskItem) -> String {
        "Mark \(task.title) \(task.isComplete ? "incomplete" : "complete")"
    }

    static func deleteLabel(for task: TaskItem) -> String {
        "Delete \(task.title)"
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Button(action: onToggle) {
                Image(systemName: task.isComplete ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(task.isComplete ? Color.accentCoral : Color.textSecondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Self.toggleLabel(for: task))

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(.body, design: .rounded, weight: .medium))
                    .lineLimit(2)
                    .strikethrough(task.isComplete)
                    .foregroundStyle(task.isComplete ? Color.white.opacity(0.45) : Color.textPrimary)

                HStack(spacing: 5) {
                    Circle()
                        .fill(task.category.color)
                        .frame(width: 6, height: 6)
                        .accessibilityHidden(true)
                    Text(task.category.label)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Hidden by opacity, not removed, so the title never reflows. Zero opacity would otherwise
            // drop it from the accessibility tree; .accessibilityHidden(false) keeps it reachable while invisible.
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.textSecondary)
            }
            .buttonStyle(.plain)
            .opacity(isHovered ? 1 : 0)
            .accessibilityLabel(Self.deleteLabel(for: task))
            .accessibilityHidden(false)
        }
        .padding(12)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .onHover { isHovered = $0 }
    }
}

#Preview {
    VStack(spacing: 8) {
        TaskRow(task: TaskItem(title: "Reply to that email", category: .focus), onToggle: {}, onDelete: {})
        TaskRow(task: TaskItem(title: "Buy oat milk", category: .life, isComplete: true), onToggle: {}, onDelete: {})
        TaskRow(
            task: TaskItem(title: "Book dentist appointment for the week after next, and check the insurance", category: .later),
            onToggle: {},
            onDelete: {}
        )
    }
    .padding()
    .frame(width: 380)
    .background(Color(red: 0.12, green: 0.11, blue: 0.14))
}
