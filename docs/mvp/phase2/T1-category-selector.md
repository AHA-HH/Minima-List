# P2-T1 — Category selector

**Phase:** [2 — Daily usability](README.md)
**Design reference:** §8.2 step 3 (optionally choose Focus, Life or Later), §9 (composer wireframe), §10 (selected category is `ContentView` state), §12 (category not by color alone)
**Depends on:** P1

## Goal

The user picks Focus, Life or Later before adding a task. New tasks get the chosen category instead of always Focus.

## Files

- `MinimaList/Views/CategorySelector.swift` (new)
- `MinimaList/Views/ContentView.swift` (edit: composer only)
- `MinimaListTests/CategorySelectorTests.swift` (new)

## Steps

1. `struct CategorySelector: View` with `@Binding var selection: TaskCategory`. It shows one button per `TaskCategory.allCases`, in that order, in a row under the composer's text field, as in the §9 wireframe (`[● Focus]  [ Life ]  [ Later ]`).
2. Each button shows the category's dot (`category.color`) and `category.label` as text, so the category never depends on color alone. The selected one is visibly different (for example, a `surfaceRaised` capsule behind it and `textPrimary` text; unselected buttons use `textSecondary` and no capsule). Use the existing tokens in `Theme.swift`; don't add new ones.
3. Accessibility: each button's label is the category label (`"Focus"`, `"Life"`, `"Later"`). The selected button gets `.accessibilityAddTraits(.isSelected)`.
4. In `ContentView`, add `@State private var category: TaskCategory = .focus`, place `CategorySelector(selection: $category)` in the composer between the text field row and the `Return to add` hint, and make `addTask()` pass `category` to `store.add`. After adding, keep the selected category (rapid capture of several tasks in one category) and keep focus in the text field as today.
5. Clicking a category must not leave the composer without focus for long: after a selection, typing should still go into the text field. If clicking a category button takes focus away, return it (for example, set `isInputFocused = true` when `category` changes). Check this in the probe and say what you found.
6. Add a `#Preview` showing each selection.

## Tests that define done

In `CategorySelectorTests.swift` (Swift Testing, `@MainActor`):

- For each `TaskCategory`, constructing `CategorySelector(selection: .constant(category))` and evaluating its `body` doesn't crash (parameterised over `TaskCategory.allCases`).
- `TaskCategory.allCases` is `[.focus, .life, .later]` (the selector's order depends on it).

Window image (README convention): the composer with Life selected after adding a Life task, showing the new row's "Life" label.

Manual checks (owner):

- Choosing Life, typing a task and pressing Return adds it with a blue dot and the word "Life". The next task added is also Life until you choose another.
- After clicking a category you can type straight away.

## Must pass

```sh
# BUILD and TEST from CLAUDE.md, then:
grep -nE 'store\.add\(title: text, category: (TaskCategory)?\.focus' MinimaList/Views/ContentView.swift && echo "FAIL: composer still hard-codes Focus"
grep -qF 'store.add(title: text, category: category)' MinimaList/Views/ContentView.swift || echo "FAIL: addTask does not pass the selected category"
grep -q 'CategorySelector(selection:' MinimaList/Views/ContentView.swift || echo "FAIL: selector not in the composer"
grep -n 'TaskStore\|UserDefaults' MinimaList/Views/CategorySelector.swift && echo "FAIL: selector must not touch data"
```

The block prints nothing when the task passes.

## Do not

- Persist the selected category (open question §16.5).
- Change `TaskItem`, `TaskCategory` or `TaskStore`.
- Touch the header, list, empty state or `TaskRow`; the `⌘N` hint is P2-T4.
- Add a picker style that hides the choices behind a pop-up; all three are visible at once.
