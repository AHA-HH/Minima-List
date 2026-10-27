# P1-T5 — `TaskRow`

**Phase:** [1 — Core loop](README.md)
**Design reference:** §8.3 (complete a task), §8.5 (delete a task), §9 (row layout, wireframe, typography), §12 (labels, color not alone)
**Depends on:** P1-T1

## Goal

One task row as in the wireframe: a completion circle, a title of up to two lines, the category as text, and a delete button that appears on hover.

## Files

- `MinimaList/Views/TaskRow.swift` (new)
- `MinimaListTests/TaskRowTests.swift` (new)

## Steps

1. `struct TaskRow: View` takes `let task: TaskItem`, `let onToggle: () -> Void` and `let onDelete: () -> Void`. It doesn't know about `TaskStore`; the shell (P1-T4) passes the closures in. That keeps the row reusable and keeps data ownership in the store.
2. Layout per the wireframe:
   - A leading `Button` with a circle (`circle` / `checkmark.circle.fill`), coral fill when complete.
   - The title: `.lineLimit(2)`, medium weight, rounded design. When complete it's dimmed and `.strikethrough()`.
   - Below the title: a small dot in `task.category.color` plus `task.category.label` as text.
   - A trailing delete `Button` (`xmark`) that shows only while the row is hovered (`.onHover`). Hide it with `.opacity(0)` while keeping it in the layout and in the accessibility tree, so the title never reflows on hover and the button stays reachable. Phase 2 adds a context menu and the animation.
   - Row background: white at about 6% opacity, 14 pt corner radius.
3. Accessibility (design §12): the toggle's label comes from a `static func toggleLabel(for task: TaskItem) -> String` returning `"Mark \(title) complete"` or `"Mark \(title) incomplete"`. The delete button is labelled `"Delete \(title)"` via a matching `static func deleteLabel(for:)`.
4. Add a `#Preview` showing an open row, a completed row and a long two-line title.

## Tests that define done

In `TaskRowTests.swift` (Swift Testing):

- `toggleLabel(for:)` returns `"Mark Reply to email complete"` for an open task titled "Reply to email", and `"Mark Reply to email incomplete"` for the same task once complete.
- `deleteLabel(for:)` returns `"Delete Reply to email"`.
- Constructing `TaskRow` with a task and no-op closures compiles and its `body` can be evaluated (smoke test).

Manual checks (owner, after P1-T4 shows rows):

- The delete button appears on hover and disappears when the pointer leaves, and the title doesn't move.
- A completed row shows a filled check, a dimmed struck-through title, and still shows its category name.

## Must pass

```sh
# BUILD and TEST from CLAUDE.md, then:
grep -n 'TaskStore' MinimaList/Views/TaskRow.swift && echo "FAIL: row must not depend on the store"
```

The block prints nothing when the task passes.

## Do not

- Reference `TaskStore`, `UserDefaults` or any persistence from the row.
- Add a context menu, swipe actions, inline editing or animations (Phase 2).
- Define new color tokens here. Use `TaskCategory.color` and plain `.white.opacity(...)`; the shared tokens arrive with P1-T4.
