import SwiftUI

/// All three categories at once, as in the §9 composer wireframe. The label sits beside the dot so the
/// category never depends on color alone (design §12).
struct CategorySelector: View {
    @Binding var selection: TaskCategory
    var onPick: () -> Void = {}

    var body: some View {
        HStack(spacing: 6) {
            ForEach(TaskCategory.allCases, id: \.self) { category in
                let isSelected = category == selection
                Button {
                    selection = category
                    onPick()
                } label: {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(category.color)
                            .frame(width: 6, height: 6)
                            .accessibilityHidden(true)
                        Text(category.label)
                            .font(.caption)
                            .foregroundStyle(isSelected ? Color.textPrimary : Color.textSecondary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(isSelected ? Color.surfaceRaised : .clear, in: Capsule())
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(category.label)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        ForEach(TaskCategory.allCases, id: \.self) { category in
            CategorySelector(selection: .constant(category))
        }
    }
    .padding()
    .frame(width: 380)
    .background(Color.widgetBackground)
}
