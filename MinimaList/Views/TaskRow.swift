import SwiftUI

struct TaskRow: View {
    let task: TaskItem
    let onToggle: () -> Void
    let onDelete: () -> Void

    @State private var isHovered = false
    @FocusState private var isDeleteFocused: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var showsDelete: Bool { isHovered || isDeleteFocused }

    static func toggleLabel(for task: TaskItem) -> String {
        "Mark \(task.title) \(task.isComplete ? "incomplete" : "complete")"
    }

    static func deleteLabel(for task: TaskItem) -> String {
        "Delete \(task.title)"
    }

    static func contextToggleTitle(for task: TaskItem) -> String {
        task.isComplete ? "Reopen" : "Mark complete"
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Button(action: onToggle) {
                Image(systemName: task.isComplete ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .contentTransition(.symbolEffect(.replace))
                    .foregroundStyle(task.isComplete ? Color.accentCoral : Color.textSecondary)
                    .animation(Motion.toggle(reduceMotion: reduceMotion), value: task.isComplete)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Self.toggleLabel(for: task))

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(.body, design: .rounded, weight: .medium))
                    .lineLimit(2)
                    .strikethrough(task.isComplete)
                    .foregroundStyle(task.isComplete ? Color.white.opacity(0.45) : Color.textPrimary)
                    .animation(Motion.toggle(reduceMotion: reduceMotion), value: task.isComplete)

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
            // Keyboard focus shows it too, so Tab never lands on an invisible button (design §15).
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.textSecondary)
            }
            .buttonStyle(.plain)
            .focused($isDeleteFocused)
            .opacity(showsDelete ? 1 : 0)
            .animation(Motion.hover(reduceMotion: reduceMotion), value: showsDelete)
            .accessibilityLabel(Self.deleteLabel(for: task))
            .accessibilityHidden(false)
        }
        .padding(12)
        .background(Color.surfaceRaised, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .onHover { isHovered = $0 }
        .contextMenu {
            Button(Self.contextToggleTitle(for: task), action: onToggle)
            Divider()
            Button("Delete", role: .destructive, action: onDelete)
        }
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
