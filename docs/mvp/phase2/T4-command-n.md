# P2-T4 — `⌘N` focuses the composer

**Phase:** [2 — Daily usability](README.md)
**Design reference:** §8.2 step 1, §11 (`⌘N` for new-task focus), §9 (keyboard hint `Return to add · ⌘N to focus`)
**Depends on:** P2-T2 (both edit `ContentView.swift`)

## Goal

`⌘N` puts the cursor in the composer. Today it does something worse: `WindowGroup`'s built-in File › New Window command is bound to `⌘N`, so it opens a **second** widget window.

## Files

- `MinimaList/MinimaListApp.swift` (edit)
- `MinimaList/Views/ContentView.swift` (edit)

## Steps

1. Add a focused value that lets a menu command reach the composer, in `ContentView.swift`:
   ```swift
   extension FocusedValues {
       @Entry var focusComposer: (() -> Void)?
   }
   ```
   If `@Entry` for `FocusedValues` isn't available at the macOS 14 deployment target, use a classic `FocusedValueKey` struct instead and say so in the PR.
2. In `ContentView`, publish it on the root view: `.focusedSceneValue(\.focusComposer) { isInputFocused = true }`.
3. In `MinimaListApp`, replace the New Window command so `⌘N` can't open a second widget:
   ```swift
   .commands {
       CommandGroup(replacing: .newItem) {
           NewTaskButton()
       }
   }
   ```
   where `NewTaskButton` is a small view in `MinimaListApp.swift` that reads `@FocusedValue(\.focusComposer)`, shows `Button("New Task") { focusComposer?() }`, uses `.keyboardShortcut("n")`, and is `.disabled(focusComposer == nil)`. (Commands can't hold `@FocusedValue` directly in all cases; a view inside the group can.)
4. Change the composer hint from `Return to add` to `Return to add · ⌘N to focus`.

## Tests that define done

- `TEST` passes. There's no new unit test: the behaviour is menu routing that only a running app shows.

Runtime probe (throwaway, README convention), reported in the PR:

- After launch, move first responder away from the composer (for example `window.makeFirstResponder(nil)`), then trigger the File menu's New Task item (`NSApp.mainMenu` → find the item with key equivalent `n` → `performAction` on its menu), and log that the composer's field editor is first responder again.
- Log `NSApp.windows.filter(\.isVisible).count` after triggering it: it must still be `1`.
- A PNG of the window showing the new hint.

Manual checks (owner):

- Click a task row (focus leaves the composer), press `⌘N`: the cursor is back in the composer and you can type.
- Pressing `⌘N` several times never opens a second widget.
- The File menu shows New Task ⌘N, and no New Window item.

## Must pass

```sh
# BUILD and TEST from CLAUDE.md, then:
grep -q 'CommandGroup(replacing: \.newItem)' MinimaList/MinimaListApp.swift || echo "FAIL: New Window still bound to ⌘N"
grep -qF '⌘N to focus' MinimaList/Views/ContentView.swift || echo "FAIL: keyboard hint not updated"
grep -n 'NSEvent\|addLocalMonitor\|addGlobalMonitor' MinimaList/ -r && echo "FAIL: use commands, not event monitors"
```

The block prints nothing when the task passes.

## Do not

- Add a global hotkey that works while another app is active (open question §16.3).
- Use `NSEvent` monitors or a hidden button with a keyboard shortcut instead of `.commands`.
- Change other command groups (Quit, Edit, Window) beyond replacing `.newItem`.
- Touch `TaskRow`, the header menu or the category selector.
