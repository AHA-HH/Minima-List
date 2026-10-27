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
                    // The coral accent token arrives with P1-T4; Focus is the same coral.
                    .foregroundStyle(task.isComplete ? TaskCategory.focus.color : .white.opacity(0.6))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Self.toggleLabel(for: task))

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(.body, design: .rounded, weight: .medium))
                    .lineLimit(2)
                    .strikethrough(task.isComplete)
                    .foregroundStyle(.white.opacity(task.isComplete ? 0.45 : 0.95))

                HStack(spacing: 5) {
                    Circle()
                        .fill(task.category.color)
                        .frame(width: 6, height: 6)
                        .accessibilityHidden(true)
                    Text(task.category.label)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Hidden by opacity, not removed, so the title never reflows and the button stays reachable.
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .buttonStyle(.plain)
            .opacity(isHovered ? 1 : 0)
            .accessibilityLabel(Self.deleteLabel(for: task))
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
