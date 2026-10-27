# Phase 1 — Core loop

**Objective:** Minima-List MVP ([design document](../../design/Minima-List.md), §15)
**Goal:** in the floating widget shell, tasks can be added, completed and deleted, and they survive a relaunch.
**Starting point:** Phase 0 is complete. `main` has a hand-written Xcode project with synchronised folders (so new files need no project edit), a sandboxed app showing the template "Hello, world!" view, one Swift Testing test, and [`CLAUDE.md`](../../../CLAUDE.md) with the layout, checks and rules every task is reviewed against.

## Tasks

Tasks in the same wave touch different files and can run in parallel.

| Wave | ID | Brief | Depends on |
| --- | --- | --- | --- |
| 1 | P1-T1 | [`TaskItem` and `Category`](T1-task-model.md) | P0 |
| 1 | P1-T3 | [Floating window](T3-floating-window.md) | P0 |
| 2 | P1-T2 | [`TaskStore` and persistence](T2-task-store.md) | P1-T1 |
| 2 | P1-T5 | [`TaskRow`](T5-task-row.md) | P1-T1 |
| 3 | P1-T4 | [Widget shell](T4-widget-shell.md) | P1-T2, P1-T3, P1-T5 |
| 4 | P1-T6 | [Empty state](T6-empty-state.md) | P1-T4 |

- [ ] P1-T1 · [ ] P1-T3 · [ ] P1-T2 · [ ] P1-T5 · [ ] P1-T4 · [ ] P1-T6

Tick an item only after both reviews pass (the thermo-nuclear code quality review and the `reviewer` agent) and the PR is merged.

## Shared commands

`BUILD` and `TEST` are defined in [`CLAUDE.md`](../../../CLAUDE.md) under **Checks**, and every brief refers to them by name. After any task that touches signing or the app target, run the sandbox check in [`../phase0/T4-sandbox.md`](../phase0/T4-sandbox.md) **right after `BUILD`**, never after `TEST`.

## Conventions for this phase

- **Testable logic lives outside views.** Window settings, greeting text and accessibility labels are plain functions that unit tests call directly. There are no UI tests; what only a person can judge is listed as a **manual check** in each brief, and the reviewer reports those as "not run (manual, owner)".
- **Tests use isolated storage.** Any test that touches `UserDefaults` uses `UserDefaults(suiteName: "test-\(UUID())")!` and removes that domain afterwards. Swift Testing runs tests in parallel, so tests must never share a suite or use `.standard`.
- **App name in the UI:** the header shows `MINIMA LIST`. The design document's text still says "Little List" (open naming question). Keep the string in one place so it's a one-line change.

## Out of scope for this phase

These belong to Phase 2 or later. The reviewer flags them as scope violations:

- Category selector in the composer (new tasks use `Category.focus`).
- Overflow menu (`•••`), Hide/Show completed, Clear completed in the UI (`TaskStore.clearCompleted()` is built and tested, but nothing calls it yet), row context menus.
- `⌘N`, hover/completion/removal animations, Reduce Motion handling.
- Undo, window-position persistence, data versioning or migration.
- Any third-party dependency, networking, or new entitlement.

## Exit criteria (from design §14)

Automated (`TEST`): every unit test listed in the briefs passes.

Manual (owner, once T6 is merged):

- [ ] Launches as a floating 380 × 610 pt widget with rounded corners and no title bar or traffic lights.
- [ ] Can be dragged by its background.
- [ ] Stays visible when switching Spaces and over a full-screen app.
- [ ] Typing a task and pressing Return adds it at the top; empty or spaces-only input adds nothing.
- [ ] Clicking a row's circle completes it, and clicking again reopens it; the progress bar and "n of m done" update immediately.
- [ ] Hovering a row shows its delete button, and clicking it removes the task.
- [ ] Quitting and relaunching keeps every task, with its completion state.
- [ ] With no tasks, the empty state shows.
