# P2-T6 — Accessibility audit

**Brief:** [T6-accessibility.md](T6-accessibility.md)
**Probe build:** `PRODUCT_BUNDLE_IDENTIFIER=probe.minimalist.t6`, three tasks with one complete (and a second run with no tasks), macOS 26 on arm64. The probe code was thrown away and not committed.

## How the tree was read

| Attempt | Result |
| --- | --- |
| `window.accessibilityChildren()` (via `accessibilityAttributeValue(.children)`), walked recursively | Only the AppKit-backed views: the hosting view, the `•••` popup button, the `NSProgressIndicator`, the scroll view and the text field cell, all with empty descriptions. No SwiftUI buttons or text. Not usable. |
| The same after `NSApp.accessibilitySetValue(true, forAttribute: "AXEnhancedUserInterface")` | No change. (`NSApplication` has no `setAccessibilityEnhancedUserInterface`.) |
| `AXUIElementSetAttributeValue(app, "AXEnhancedUserInterface", true)` on `AXUIElementCreateApplication(getpid())` | Returned `-25208` (attribute unsupported). |
| `AXUIElementCopyAttributeValue` walk from `AXUIElementCreateApplication(getpid())` | **Works**, although `AXIsProcessTrusted()` is `false`: the app may query its own elements. This is the full tree an assistive client sees, and the dumps below come from it. |

Columns: role, `AXDescription` (the accessibility label), `AXValue`, `AXValueDescription` (what VoiceOver reads for a value, where present), `AXEnabled`, `AXSelected`. `-` means the attribute is absent. Static text carries its words in `AXValue`, which is what VoiceOver reads. The menu bar is left out.

### Before (main at d16ad44)

```text
AXWindow
  AXGroup
    AXStaticText        value="MINIMA LIST"
    AXMenuButton        desc="More"
    AXStaticText        value="Good morning"
    AXStaticText        value="Wednesday 28 October"
    AXProgressIndicator desc=-  value="0.3333333333333333"
    AXStaticText        value="1 of 3 done"
    AXScrollArea
      AXOpaqueProviderGroup
        AXButton        desc="Mark Book dentist complete"
        AXStaticText    value="Book dentist"
        AXStaticText    value="Later"
        AXButton        desc="Delete Book dentist"
        AXButton        desc="Mark Buy oat milk incomplete"
        AXStaticText    value="Buy oat milk"
        AXStaticText    value="Life"
        AXButton        desc="Delete Buy oat milk"
        AXButton        desc="Mark Reply to that email complete"
        AXStaticText    value="Reply to that email"
        AXStaticText    value="Focus"
        AXButton        desc="Delete Reply to that email"
    AXTextField         desc=-  value=""
    AXButton            desc="Add task"
    AXButton            desc="Focus"
    AXButton            desc="Life"
    AXButton            desc="Later"
    AXStaticText        value="Return to add · ⌘N to focus"
```

Every element is enabled. The empty-state tree was not captured before the fix.

### After

```text
AXWindow
  AXGroup
    AXStaticText        value="MINIMA LIST"
    AXMenuButton        desc="More"
    AXStaticText        value="Good morning"
    AXStaticText        value="Wednesday 28 October"
    AXProgressIndicator desc="Progress"  value="0.3333333333333333"  valueDesc="1 of 3 done"
    AXScrollArea
      AXOpaqueProviderGroup
        AXButton        desc="Mark Book dentist complete"
        AXStaticText    value="Book dentist"
        AXStaticText    value="Later"
        AXButton        desc="Delete Book dentist"
        AXButton        desc="Mark Buy oat milk incomplete"  selected=1
        AXStaticText    value="Buy oat milk"
        AXStaticText    value="Life"
        AXButton        desc="Delete Buy oat milk"
        AXButton        desc="Mark Reply to that email complete"
        AXStaticText    value="Reply to that email"
        AXStaticText    value="Focus"
        AXButton        desc="Delete Reply to that email"
    AXTextField         desc="New task"  focused=1
    AXButton            desc="Add task"
    AXButton            desc="Focus"  selected=1
    AXButton            desc="Life"
    AXButton            desc="Later"
    AXStaticText        value="Return to add · ⌘N to focus"
```

Empty state (no tasks):

```text
    AXProgressIndicator desc="Progress"  value="0"  valueDesc="0 of 0 done"
    AXStaticText        value="Nothing here yet., What's one thing to do?"
    AXTextField         desc="New task"
```

**Runtime probe:** no button, menu button or text field has an empty label, and every row has its delete button in the tree (three rows, three `Delete …` buttons), as the brief requires.

### Keyboard focus in the probe

Keyboard navigation is off on the probe machine, and the probe did not change the owner's global setting (launching with `-AppleKeyboardUIMode 2` did not turn it on), so synthesised Tab presses stayed in the text field. Instead the probe set `AXFocused` on elements, which is what VoiceOver and Full Keyboard Access do:

| Step | Result |
| --- | --- |
| Set `AXFocused` on `Delete Book dentist` | Focus moved to it, and the `×` became visible on that row only, with no hover. |
| Set `AXFocused` on `Life` | Focus moved to it, and the system focus ring drew around the capsule. |
| `AXPress` on `Life` (what Space does) | `Life` became selected and focus went back to the composer (`AXTextField desc="New task" focused=1`), which now shows its focus ring. |

The real Tab walk is in the owner's walkthrough below.

## Gaps and fixes

| # | Gap | Fix |
| --- | --- | --- |
| 1 | The composer text field had no label (`desc` absent); VoiceOver only had the placeholder. | `.accessibilityLabel("New task")`, matching File › New Task. |
| 2 | The progress bar had no label and read as a bare fraction, and "1 of 3 done" was a separate element after it. | The bar is labelled "Progress" and its value is the "1 of 3 done" text, from the new `ContentView.progressLabel(completed:total:)` (unit tested). The visible text uses the same function and is hidden from VoiceOver so it isn't read twice. |
| 3 | The empty state's decorative `circle` symbol was inside the combined element. | `.accessibilityHidden(true)` on the image. The empty state now reads as one element: "Nothing here yet., What's one thing to do?" |
| 4 | The delete button stayed at zero opacity when it had keyboard focus. | `@FocusState` in `TaskRow`. The button shows when the row is hovered **or** the button is focused. It stays in the tree and in the key loop. |
| 5 | The plain-style composer drew no focus ring (the launch image shows the focused field with no ring). | A 2 pt stroke in the system `keyboardFocusIndicatorColor` around the field while it is focused. It is the system focus colour, not a new palette colour. |
| 6 | After a category was picked with Tab and Space, focus stayed on the category button, where Return does nothing, so the walkthrough's "add it with Return" failed. | `.onChange(of: category) { isInputFocused = true }`. Picking a category returns focus to the composer, so Return adds the task. A mouse click already left focus in the field, so it is unchanged. Trade-off: after a keyboard pick, focus jumps back to the composer rather than staying on the selector, and AppKit selects the field's text on refocus, as it does on any Tab into a field. |

Checked and left alone:

- **Category buttons** already had their name plus the selected trait (`selected=1` on the chosen one). The probe shows the system focus ring around a focused category capsule, so they needed no focus fix.
- **Add task**, **toggle** and **delete** labels from P1-T5 are meaningful. The header reads in order: "MINIMA LIST", the `More` menu, greeting, date, progress.
- **`•••` hit target** is about 25 × 14 pt. Its label ("More") is right. Enlarging it would grow the header row and shift the layout, which the brief rules out unless a fix needs it, and §12 sets no target size. Left for the owner to decide, possibly with P3 polish.
- **Toggle wording vs. context menu:** the toggle reads "Mark *title* incomplete", while the context menu says "Reopen". Both say what they do. The toggle follows design §12's "Mark reply to email complete" pattern, and the context menu sits on the row, so it doesn't need the title. Not a naming gap; left as is.
- **Completed toggle reports `selected=1`.** SwiftUI adds this to the completed row's toggle. VoiceOver may add "selected" after "Mark *title* incomplete", which is accurate. Left as is.
- **Row announcement:** each row reads its toggle (title and state), title, category name and delete button, in that order. The completed state is in the toggle label; the strikethrough isn't read.

## Owner walkthrough

Run with keyboard navigation on (System Settings › Keyboard › Keyboard navigation). Fill in the Result column.

| # | Step | Expected | Result |
| --- | --- | --- | --- |
| 1 | Launch, then type a task without touching the mouse. | Typing goes into the composer, which shows a focus ring. | |
| 2 | Tab to Life and press Space. | Tab passes Add task and Focus with a visible focus ring; Space selects Life and focus returns to the composer. | |
| 3 | Press Return. | The task is added with the Life category. | |
| 4 | Tab to the new task's circle and press Space. | It is marked complete. | |
| 5 | Tab to the same row's delete button. | The `×` appears while it has focus. | |
| 6 | Press Space. | The task is deleted. | |
| 7 | Tab to `•••`, open it with Space, choose Hide completed. | Completed rows are hidden. | |
| 8 | Press ⌘N. | Focus returns to the composer; no second window opens. | |
| 9 | Turn on VoiceOver (⌘F5) and move through the whole widget. | Every control is announced with a name that says what it does; the progress bar reads "N of M done". | |
| 10 | With VoiceOver, move over the empty state (no tasks, or all hidden). | It is read as one sentence with no "circle". | |
| 11 | With VoiceOver, move through a row. | It announces the title, category and state. | |
