# P1-T6 — Empty state

**Phase:** [1 — Core loop](README.md)
**Design reference:** §9 (empty-state wireframe), §13 (edge states)
**Depends on:** P1-T4

## Goal

When there are no tasks, the list area shows a quiet invitation instead of blank space.

## Files

- `MinimaList/Views/ContentView.swift` (edit)

## Steps

1. When `store.tasks.isEmpty`, show this in place of the `ScrollView`, centred in the list area: a large `circle` symbol in `textSecondary`, then `Nothing here yet.` in `textPrimary` and `What's one thing to do?` in `textSecondary`, matching the §9 empty-state wireframe.
2. The header and composer don't change, and the progress text reads `0 of 0 done` with an empty bar (`TaskStore.progress` is already `0`).
3. The empty state is read by VoiceOver as one element: `.accessibilityElement(children: .combine)`.

4. **Focus on launch.** The composer only takes focus after an add (P1-T4 review), so on a fresh launch the user must click it first. Give it focus when the window appears, for example `.defaultFocus($isInputFocused, true)` or setting `isInputFocused = true` in `.onAppear`.
5. **Keep the header current.** The greeting and date are only re-read when a task changes, so a widget left open overnight shows yesterday's greeting and date (P1-T4 review). Wrap just the greeting and date in `TimelineView(.everyMinute)` and pass its `context.date` to `greeting(for:)` and the date formatter. Don't put the list or composer inside the timeline.

Phase 2 reuses this same view when completed tasks are hidden and nothing is left visible. Don't build that condition now; just keep the empty state a single `@ViewBuilder` property or small private view, so Phase 2 can change the condition in one place.

## Tests that define done

- `TEST` passes (no new unit test: the empty state is pure layout with no logic).

Manual checks (owner; record results in the review):

- On a fresh launch with no saved tasks, the empty state shows and you can type straight away without clicking the composer.
- Adding a task replaces the empty state with the list. Deleting that task brings the empty state back.

## Must pass

```sh
# BUILD and TEST from CLAUDE.md, then:
grep -qF "Nothing here yet." MinimaList/Views/ContentView.swift || echo "FAIL: empty-state text missing"
```

The block prints nothing when the task passes.

## Do not

- Add sample or example tasks on first launch (design §8.2: the list starts empty).
- Add illustrations, animation or onboarding copy beyond the two lines.
- Touch any file other than `ContentView.swift`.
- Re-render the list or composer every minute; only the greeting and date belong in the `TimelineView`.
