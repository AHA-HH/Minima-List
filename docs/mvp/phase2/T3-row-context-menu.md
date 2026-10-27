# P2-T3 — Row context menu

**Phase:** [2 — Daily usability](README.md)
**Design reference:** §8.5 (delete also in the context menu), §9 (row context menu wireframe), §12 (delete reachable without hover)
**Depends on:** P1

## Goal

Right-clicking (or Control-clicking) a row offers Mark complete or Reopen, and Delete, so neither action needs the hover button.

## Files

- `MinimaList/Views/TaskRow.swift` (edit)
- `MinimaListTests/TaskRowTests.swift` (edit)

## Steps

1. Add `static func contextToggleTitle(for task: TaskItem) -> String`, returning `"Mark complete"` for an open task and `"Reopen"` for a completed one, next to the existing label functions.
2. Add `.contextMenu` to the row, laid out as in the §9 wireframe: a button titled `contextToggleTitle(for: task)` that calls `onToggle`, a `Divider()`, then a `Button("Delete", role: .destructive)` that calls `onDelete`.
3. The menu applies to the whole row, including its padding, so right-clicking anywhere on the row's background opens it. If the menu only opens over the text, give the row a content shape (`.contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))`).
4. Reuse the existing closures; the row still doesn't know about `TaskStore`.

## Tests that define done

In `TaskRowTests.swift`:

- `contextToggleTitle(for:)` returns `"Mark complete"` for an open task and `"Reopen"` for the same task once complete.
- The existing label and `body` smoke tests still pass.

Manual checks (owner):

- Right-clicking an open row shows Mark complete and Delete; choosing Mark complete completes it and the progress updates.
- Right-clicking a completed row shows Reopen.
- Delete from the menu removes only that task.
- Right-clicking in the row's padding (not on the text) still opens the menu.

## Must pass

```sh
# BUILD and TEST from CLAUDE.md, then:
grep -q '\.contextMenu' MinimaList/Views/TaskRow.swift || echo "FAIL: no context menu"
grep -n 'TaskStore' MinimaList/Views/TaskRow.swift && echo "FAIL: row must not depend on the store"
```

The block prints nothing when the task passes.

## Do not

- Add more menu items (edit, change category, duplicate) than the wireframe shows.
- Add a confirmation or undo for Delete (Phase 3).
- Touch `ContentView.swift` or add animations (P2-T5).
