# P2-T6 — Accessibility pass

**Phase:** [2 — Daily usability](README.md)
**Design reference:** §12 (accessibility requirements), §15 technical risks ("hover-only delete is unreachable by keyboard")
**Depends on:** P2-T1 to P2-T5

## Goal

Every control has a meaningful name, the core flow works with the keyboard alone, and VoiceOver reads the widget sensibly. This task audits what Phase 1 and 2 built and fixes the gaps; it adds no features.

## Files

- Any file in `MinimaList/Views/`, only where the audit finds a gap.
- `MinimaListTests/` (edit or new), for any new label function.
- `docs/mvp/phase2/T6-accessibility-audit.md` (new): the audit record.

## Steps

1. **Audit the accessibility tree.** In a throwaway probe (README convention), after launch with a few tasks (one complete), walk the window's accessibility hierarchy from `window.accessibilityChildren()` down, and log each element's role, label, value, and whether it is enabled and focusable. Write the dump into the audit record.
2. **Fix every control without a meaningful name.** Known places to check:
   - The `•••` menu (`More`), the add button (`Add task`), each category button (its name plus selected state), the row toggle and delete buttons (P1-T5 labels).
   - The empty state's decorative `circle` symbol should be hidden from VoiceOver so it reads "Nothing here yet. What's one thing to do?" without "circle".
   - The progress bar should read as progress, for example "2 of 5 done".
   - The header greeting and date read as text, in order.
3. **Make the hover-only delete reachable and visible by keyboard.** With keyboard navigation on (System Settings › Keyboard › Keyboard navigation), Tab must be able to reach each row's toggle and delete buttons, and the delete button must become visible while it has keyboard focus (today it stays at zero opacity). Show it when the row is hovered **or** the delete button is focused (for example `@FocusState` in `TaskRow`). Pressing Space on a focused button activates it.
4. **Visible focus.** The composer and category buttons show a focus indication when reached by keyboard (design §12). Don't remove system focus rings anywhere.
5. **Write the audit record** (`T6-accessibility-audit.md`): the before-and-after accessibility dump, each gap found and how it was fixed, and a table of the owner's walkthrough steps (below) with a Result column left blank for the owner.

## Tests that define done

- Any new label is produced by a `static func` with a unit test, as in `TaskRow.toggleLabel(for:)`.
- `TEST` passes.

Runtime probe (reported in the audit record): after the fixes, the dump shows no button, menu or text field with an empty label, and the delete button is in the tree for every row.

Manual walkthroughs (owner; record results in the audit record):

- **Keyboard only**, with keyboard navigation on and without touching the mouse after launch: type a task, choose Life with Tab and Space, add it with Return, Tab to its circle and complete it, Tab to its delete button (it becomes visible) and delete it, open `•••` and hide completed, press `⌘N` to get back to the composer.
- **VoiceOver** (⌘F5): move through the whole widget. Every control is announced with a name that says what it does, the empty state is read as one sentence, and each row announces its title, category and state.

## Must pass

```sh
# BUILD and TEST from CLAUDE.md, then:
test -f docs/mvp/phase2/T6-accessibility-audit.md || echo "FAIL: audit record missing"
grep -rn 'accessibilityLabel("")' MinimaList/Views/ && echo "FAIL: empty accessibility label"
grep -rn 'focusEffectDisabled\|focusable(false)' MinimaList/Views/ && echo "FAIL: don't remove keyboard focus"
```

The block prints nothing when the task passes.

## Do not

- Change colors or contrast (P3-T5) or layout beyond what a fix needs.
- Add features, shortcuts or menu items.
- Mark the owner's walkthroughs as passed; only the owner fills in the Result column.
