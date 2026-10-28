# Phase 2 — Daily usability

**Objective:** Minima-List MVP ([design document](../../design/Minima-List.md), §15)
**Goal:** close the remaining §14 criteria (categories, hide and clear completed, context menu, `⌘N`, motion and accessibility). This completes the MVP.
**Starting point:** Phase 1 is complete. `main` has the floating 380 × 610 widget with a header, a scrolling list of `TaskRow`s, a composer that always adds `TaskCategory.focus`, and an empty state. `TaskStore` already has `clearCompleted()` (built and tested in P1-T2, not yet called by the UI). There are 21 tests in 6 suites.

## Tasks

Tasks in the same wave touch different files and can run in parallel. T1, T2, T4 and T5 all edit `ContentView.swift`, so they run one after another.

| Wave | ID | Brief | Depends on |
| --- | --- | --- | --- |
| 1 | P2-T1 | [Category selector](T1-category-selector.md) | P1 |
| 1 | P2-T3 | [Row context menu](T3-row-context-menu.md) | P1 |
| 2 | P2-T2 | [Overflow menu](T2-overflow-menu.md) | P2-T1 |
| 3 | P2-T4 | [`⌘N` focuses the composer](T4-command-n.md) | P2-T2 |
| 4 | P2-T5 | [Motion and Reduce Motion](T5-motion.md) | P2-T3, P2-T4 |
| 5 | P2-T6 | [Accessibility pass](T6-accessibility.md) | P2-T1 to P2-T5 |

- [x] P2-T1 · [x] P2-T3 · [x] P2-T2 · [x] P2-T4 · [x] P2-T5 · [x] P2-T6

Tick an item only after both reviews pass (the thermo-nuclear code quality review and the `reviewer` agent) and the PR is merged.

## Shared commands

`BUILD` and `TEST` are defined in [`CLAUDE.md`](../../../CLAUDE.md) under **Checks**. After any task that touches signing or the app target, run the sandbox check in [`../phase0/T4-sandbox.md`](../phase0/T4-sandbox.md) **right after `BUILD`**, never after `TEST`.

## Conventions for this phase

All Phase 1 conventions still apply: testable logic lives in plain or `static` functions that unit tests call directly, tests use isolated `UserDefaults` suites, and `MINIMA LIST` is the app name in the UI. In addition:

- **A window image for every visual change.** In Phase 1 every automated check passed while a grey title-bar band covered the top of the widget; only the owner's eyes caught it. So for any task that changes what the widget draws, the implementer and the thermo-nuclear reviewer each run a throwaway copy of the app and look at a PNG of its window:
  - Build with a separate bundle ID (`PRODUCT_BUNDLE_IDENTIFIER=probe.minimalist.<task>`) so the owner's tasks are never touched.
  - About 2 s after launch, render the window's frame view (`window.contentView?.superview`) with `bitmapImageRepForCachingDisplay` and `cacheDisplay`, and write the PNG to the app's sandbox temp folder (`~/Library/Containers/probe.minimalist.<task>/Data/tmp/`). This needs no screen-recording permission.
  - Copy the PNG to the scratchpad, give its absolute path in the PR or review, and quit the probe. Never commit probe code.
- **Transient UI state stays in the view.** The selected category, whether completed tasks are hidden, and composer focus are `ContentView` state (design §10). Don't persist them; whether to remember them between launches is open question §16.5.
- **Menus are SwiftUI.** Use `Menu`, `.contextMenu` and `.commands`. No `NSMenu`.

## Out of scope for this phase

These belong to Phase 3 or later. The reviewer flags them as scope violations:

- Undo for delete or clear completed, or a confirmation dialog for clear completed (design §8.4 allows it to be direct in the MVP).
- Persisting the window position, the selected category or the hide-completed setting.
- Data versioning or migration.
- Changing the default size, copy, spacing or colors beyond what a brief asks for (contrast tuning is P3-T5).
- Renaming categories, user-defined categories, inline title editing, drag to reorder.
- Launch at login, a menu-bar item or a global hotkey (open questions §16.1 and §16.3).
- Any third-party dependency, networking or new entitlement.

## Exit criteria (from design §14)

Automated (`TEST`): every unit test listed in the briefs passes, including the visible-list test in P2-T2. (`clearCompleted` removing only completed tasks is already covered by `TaskStoreTests` from P1-T2.)

Manual (owner, once T6 is merged):

- [ ] A category can be chosen before adding a task, and the new row shows that category's name and color.
- [ ] Hide completed hides every completed row, and Show completed brings them back. With every task complete and completed hidden, the empty state shows.
- [ ] Clear completed removes only completed tasks.
- [ ] Right-clicking a row offers Mark complete (or Reopen) and Delete, and both work.
- [ ] `⌘N` focuses the composer and never opens a second widget window.
- [ ] Completing, hovering and deleting animate gently. With Reduce Motion on, the spring and slide are gone.
- [ ] The core flow (add with a category, complete, delete, hide completed) works using only the keyboard, and with VoiceOver every control is announced with a meaningful name.
