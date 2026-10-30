import SwiftUI

/// The collapsed floating window: a circle with the open-task count (design §8.7).
struct CountBubble: View {
    let openCount: Int
    let onExpand: () -> Void

    /// `nil` means no open tasks, which draws a check mark instead of `0`.
    static func countText(openCount: Int) -> String? {
        openCount == 0 ? nil : String(openCount)
    }

    static func accessibilityLabel(openCount: Int) -> String {
        switch openCount {
        case 0: "No open tasks"
        case 1: "1 open task"
        default: "\(openCount) open tasks"
        }
    }

    var body: some View {
        Button(action: onExpand) {
            Group {
                if let text = Self.countText(openCount: openCount) {
                    Text(text)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .padding(.horizontal, 8)
                } else {
                    Image(systemName: "checkmark")
                }
            }
            .font(.title2.weight(.semibold))
            .fontDesign(.rounded)
            .foregroundStyle(Color.textPrimary)
            .frame(width: 56, height: 56)
            .background(Color.widgetBackground, in: Circle())
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Self.accessibilityLabel(openCount: openCount))
        .accessibilityHint("Expands Minima List")
        .help("Expand")
    }
}
