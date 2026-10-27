# P2-T2 — Overflow menu

**Phase:** [2 — Daily usability](README.md)
**Design reference:** §8.4 (hide, clear, quit), §9 (header and overflow menu wireframes), §10 (visibility is `ContentView` state), §13 (completed hidden → empty state)
**Depends on:** P2-T1 (both edit `ContentView.swift`)

## Goal

A `•••` menu in the header with Hide/Show completed, Clear completed and Quit. When completed tasks are hidden and nothing else is left, the empty state shows.

## Files

- `MinimaList/Views/ContentView.swift` (edit)
- `MinimaListTests/ContentViewTests.swift` (new)

## Steps

1. Add `static func visibleTasks(_ tasks: [TaskItem], hidingCompleted: Bool) -> [TaskItem]` on `ContentView`. It returns `tasks` unchanged when `hidingCompleted` is false, and only the open tasks, in their original order, when it is true.
2. Add `@State private var isHidingCompleted = false`. The list and the empty-state condition both use `Self.visibleTasks(store.tasks, hidingCompleted: isHidingCompleted)`, so there is still exactly one condition that chooses between the list and the empty state (P1-T6 kept it in one place for this).
3. In the header, put a `Menu` on the same line as `MINIMA LIST`, aligned right, as in the §9 wireframe. Its label is the `ellipsis` symbol in `textSecondary`, with no menu indicator (`.menuIndicator(.hidden)`) and a borderless style, and `.accessibilityLabel("More")`. Items, top to bottom:
   - `Hide completed` or `Show completed`, toggling `isHidingCompleted`.
   - `Clear completed`, calling `store.clearCompleted()`. Disabled when `store.completedCount == 0`.
   - `Divider()`.
   - `Quit Minima List`, calling `NSApplication.shared.terminate(nil)`, with `.keyboardShortcut("q")` so the menu shows ⌘Q.
4. The progress bar and `n of m done` keep counting all tasks, hidden or not.
5. The header's `TimelineView` still wraps only the greeting and date; the menu sits outside it.

## Tests that define done

In `ContentViewTests.swift` (Swift Testing, `@MainActor`), building `TaskItem`s directly (no store needed):

- With `hidingCompleted: false`, `visibleTasks` returns every task in the same order.
- With `hidingCompleted: true`, it returns only the open tasks, in the same order.
- With every task complete and `hidingCompleted: true`, it returns an empty array (this is what shows the empty state; design §15 Phase 2 unit test).
- With no tasks, it returns an empty array for both values.

Window image (README convention): the header with the `•••` button visible, and a second image with completed tasks hidden.

Manual checks (owner):

- `•••` opens the menu. Hide completed hides completed rows and the item then reads Show completed.
- With every task complete, Hide completed shows the empty state, and the progress still reads `n of n done`.
- Clear completed removes only the completed tasks, and is greyed out when none are complete.
- Quit Minima List quits the app.

## Must pass

```sh
# BUILD and TEST from CLAUDE.md, then:
for s in "Hide completed" "Show completed" "Clear completed" "Quit Minima List"; do
  grep -qF "$s" MinimaList/Views/ContentView.swift || echo "FAIL: missing menu item: $s"
done
grep -c 'visibleTasks(' MinimaList/Views/ContentView.swift | grep -qx '[2-9]' || echo "FAIL: visibleTasks is defined but never used"
grep -rn 'UserDefaults\|@AppStorage' MinimaList/Views/ && echo "FAIL: hide state must not be persisted"
```

The block prints nothing when the task passes.

## Do not

- Persist `isHidingCompleted` (open question §16.2 and the README's transient-state convention).
- Add a confirmation dialog or undo for Clear completed (Phase 3).
- Add `TaskStore` API; filtering is a view concern (P1-T2 "Do not").
- Touch the composer, the category selector or `TaskRow`.
