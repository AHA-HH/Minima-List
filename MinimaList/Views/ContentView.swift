import SwiftUI

struct ContentView: View {
    let store: TaskStore

    @State private var text = ""
    @State private var category: TaskCategory = .focus
    @State private var isHidingCompleted = false
    @FocusState private var isInputFocused: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    static func visibleTasks(_ tasks: [TaskItem], hidingCompleted: Bool) -> [TaskItem] {
        hidingCompleted ? tasks.filter { !$0.isComplete } : tasks
    }

    static func progressLabel(completed: Int, total: Int) -> String {
        "\(completed) of \(total) done"
    }

    var body: some View {
        let visibleTasks = Self.visibleTasks(store.tasks, hidingCompleted: isHidingCompleted)
        VStack(spacing: 0) {
            header
            // A ZStack so the empty state and list crossfade in one frame instead of splitting the height.
            ZStack {
                if visibleTasks.isEmpty {
                    emptyState
                        .transition(.opacity)
                } else {
                    list(visibleTasks)
                        .transition(.opacity)
                }
            }
            .frame(maxHeight: .infinity)
            // Keyed on the visible rows, so every path that adds or removes one animates, toggling while hidden included.
            .animation(Motion.removal(reduceMotion: reduceMotion), value: visibleTasks.map(\.id))
            composer
        }
        .defaultFocus($isInputFocused, true)
        .focusedSceneValue(\.focusComposer) { isInputFocused = true }
        .fontDesign(.rounded)
        .frame(width: 380, height: 610)
        .background(Color.widgetBackground)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("MINIMA LIST")
                    .font(.caption.bold())
                    .tracking(1.5)
                    .foregroundStyle(Color.textSecondary)
                Spacer()
                overflowMenu
            }
            // Only the greeting and date tick, so a widget left open overnight stays current.
            TimelineView(.everyMinute) { context in
                VStack(alignment: .leading, spacing: 6) {
                    Text(greeting(for: context.date))
                        .font(.largeTitle.weight(.semibold))
                        .foregroundStyle(Color.textPrimary)
                    Text(context.date, format: .dateTime.weekday(.wide).day().month(.wide))
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                }
            }
            let progress = Self.progressLabel(completed: store.completedCount, total: store.tasks.count)
            HStack(spacing: 10) {
                ProgressView(value: store.progress)
                    .tint(Color.accentCoral)
                    .accessibilityLabel("Progress")
                    .accessibilityValue(progress)
                // The bar already reads this as its value.
                Text(progress)
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
                    .accessibilityHidden(true)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 16)
    }

    private var overflowMenu: some View {
        Menu {
            Button(isHidingCompleted ? "Show completed" : "Hide completed") { isHidingCompleted.toggle() }
            Button("Clear completed") { store.clearCompleted() }
                .disabled(store.completedCount == 0)
            Divider()
            Button("Quit Minima List") { NSApplication.shared.terminate(nil) }
                .keyboardShortcut("q")
        } label: {
            Image(systemName: "ellipsis")
                .foregroundStyle(Color.textSecondary)
        }
        .menuIndicator(.hidden)
        .menuStyle(.button)
        .buttonStyle(.borderless)
        .fixedSize()
        .accessibilityLabel("More")
    }

    private func list(_ tasks: [TaskItem]) -> some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(tasks) { task in
                    TaskRow(
                        task: task,
                        onToggle: { store.toggle(task.id) },
                        onDelete: { store.remove(task.id) }
                    )
                    .transition(Motion.rowTransition(reduceMotion: reduceMotion))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
        .frame(maxHeight: .infinity)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "circle")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(Color.textSecondary)
                .padding(.bottom, 4)
                .accessibilityHidden(true)
            Text("Nothing here yet.")
                .foregroundStyle(Color.textPrimary)
            Text("What's one thing to do?")
                .foregroundStyle(Color.textSecondary)
        }
        .accessibilityElement(children: .combine)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var composer: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                TextField("Add a task…", text: $text)
                    .textFieldStyle(.plain)
                    .foregroundStyle(Color.textPrimary)
                    .focused($isInputFocused)
                    .onSubmit(addTask)
                    .accessibilityLabel("New task")
                    .padding(12)
                    .background(Color.surfaceRaised, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    // The plain style draws no focus ring, so draw the system one (design §12).
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color(nsColor: .keyboardFocusIndicatorColor), lineWidth: 2)
                            .opacity(isInputFocused ? 1 : 0)
                    }
                Button(action: addTask) {
                    Image(systemName: "plus")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.widgetBackground)
                        .frame(width: 40, height: 40)
                        .background(Color.accentCoral, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add task")
            }
            CategorySelector(selection: $category)
                // Back to the composer after picking, so Return adds the task as the keyboard walkthrough expects.
                .onChange(of: category) { isInputFocused = true }
            Text("Return to add · ⌘N to focus")
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 20)
    }

    private func addTask() {
        store.add(title: text, category: category)
        text = ""
        isInputFocused = true
    }
}

// A classic key, because `@Entry` warns that a closure value may invalidate dependents on every update.
private struct FocusComposerKey: FocusedValueKey {
    typealias Value = () -> Void
}

extension FocusedValues {
    var focusComposer: (() -> Void)? {
        get { self[FocusComposerKey.self] }
        set { self[FocusComposerKey.self] = newValue }
    }
}

#Preview {
    let store = TaskStore(defaults: UserDefaults(suiteName: "preview-\(UUID())")!)
    store.add(title: "Buy oat milk", category: .life)
    store.add(title: "Book dentist appointment for the week after next", category: .later)
    store.add(title: "Reply to that email", category: .focus)
    store.toggle(store.tasks[2].id)
    return ContentView(store: store)
}
