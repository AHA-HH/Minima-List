# P3-T2 — Pin and collapse to a count bubble

**Phase:** [3 — Menu bar and voice](README.md)
**Design reference:** §8.7 (count bubble), §9 (header wireframe with the pin), §10 (collapsed is session state), §11 (swap the window's content; keep its top-left corner), §12 (accessibility)
**Depends on:** P3-T1 (both edit `ContentView.swift` and `MinimaListApp.swift`)

## Goal

A pin button in the floating window's header collapses it to a 56 pt circle showing the number of open tasks, or a check mark when there are none. The circle floats above other windows, follows you to other Spaces and can be dragged. Clicking it brings the full widget back in the same place.

## Files

- `MinimaList/Model/TaskStore.swift` (edit)
- `MinimaList/Views/CountBubble.swift` (new)
- `MinimaList/Views/FloatingWidget.swift` (new)
- `MinimaList/Views/ContentView.swift` (edit)
- `MinimaList/MinimaListApp.swift` (edit)
- `MinimaListTests/TaskStoreTests.swift` (edit)
- `MinimaListTests/CountBubbleTests.swift` (new)
- `MinimaList/Platform/WindowConfigurator.swift` and `MinimaListTests/WindowConfiguratorTests.swift` (edit, only if the position check in step 6 fails)

## Steps

1. Add `var openCount: Int { tasks.count - completedCount }` to `TaskStore`.
2. Create `CountBubble` in `Views/CountBubble.swift`. It takes `openCount: Int` and an `onExpand: () -> Void` action, and has two static functions that the tests call:
   - `static func countText(openCount: Int) -> String?` returns `nil` at `0`, which means draw the `checkmark` symbol, and otherwise the count as a string.
   - `static func accessibilityLabel(openCount: Int) -> String` returns `No open tasks`, `1 open task` or `n open tasks`.

   The body is a `Button(action: onExpand)` with `.buttonStyle(.plain)`. Its label is a 56 × 56 `Circle` filled with `widgetBackground`, showing the count text or the `checkmark` symbol in `textPrimary`, rounded and semibold, with `.minimumScaleFactor` so large counts still fit. Add `.accessibilityLabel(Self.accessibilityLabel(openCount:))`, `.accessibilityHint("Expands Minima List")` and `.help("Expand")`.
3. Create `FloatingWidget` in `Views/FloatingWidget.swift`. It takes the `store` and `isFloatingWindowShown`, and owns `@State private var isCollapsed = false`. Its body shows `CountBubble(openCount: store.openCount) { isCollapsed = false }` when collapsed, and otherwise `ContentView(store: store, isFloatingWindowShown: isFloatingWindowShown, onPin: { isCollapsed = true })`. The swap is not animated, so Reduce Motion needs no special case.
4. In `ContentView`, add `var onPin: (() -> Void)? = nil`. When it is non-nil, show a pin button in the header between `MINIMA LIST`'s spacer and `•••`, as in the §9 wireframe: the `pin` symbol in `textSecondary`, borderless, with `.accessibilityLabel("Collapse to bubble")` and `.help("Collapse to bubble")`. The panel passes no `onPin`, so it has no pin button.
5. In `MinimaListApp`, the `Window` scene's content becomes `FloatingWidget(...)` wrapped in `WindowAccessor` as before. The `.onAppear` and `.onDisappear` from P3-T1 move with it.
6. Check the three window risks before adding anything else, and record each result in the PR:
   - **Position.** Does collapsing and expanding keep the window's top-left corner in place? AppKit's origin is bottom-left, so a `.contentSize` window may shrink towards its bottom-left. If it moves, add `static func topLeftAnchoredFrame(from old: NSRect, size: NSSize) -> NSRect` to `WindowConfigurator`, unit-test it, and apply it from `ConfiguringView` on `NSWindow.didResizeNotification`. Don't save the position anywhere else.
   - **Shadow.** Does the collapsed window's shadow follow the circle, not a square? If not, call `window.invalidateShadow()` after the resize in the same `Platform/` code.
   - **Drag.** Can the bubble be dragged by its body? `isMovableByWindowBackground` may not reach through a SwiftUI `Button`. If it can't, replace the `Button` with `.onTapGesture`, and keep the accessibility label, `.accessibilityAddTraits(.isButton)` and an `.accessibilityAction` that expands, so VoiceOver and the keyboard still work.

## Tests that define done

In `TaskStoreTests.swift`, extend the existing count test or add one next to it: with three tasks and one complete, `openCount` is `2`; with none, it's `0`.

In `CountBubbleTests.swift` (Swift Testing, `@MainActor`):

- `countText(openCount: 0)` is `nil`, so the check mark shows (design §8.7).
- `countText(openCount: 1)` is `"1"` and `countText(openCount: 12)` is `"12"`.
- `accessibilityLabel` reads `No open tasks`, `1 open task` and `3 open tasks` for 0, 1 and 3.

If step 6 adds `topLeftAnchoredFrame`, test it in `WindowConfiguratorTests.swift`: shrinking a frame keeps `minX` and `maxY`, and growing it back restores the original frame.

Window images (README convention):

- The header with the pin button next to `•••`.
- The collapsed bubble with a count, and with no open tasks (the check mark). Each must be a circle with no square corners or square shadow.
- Log the window's top-left point before collapsing, after collapsing and after expanding. All three must match.

Manual checks (owner):

- The pin collapses the floating window to a circle with the open-task count; completing a task in the panel changes the count at once.
- The circle stays above other windows, follows you to another Space, and can be dragged.
- Clicking the circle expands the widget with its top-left corner where the circle's was.
- The panel has no pin button.
- With VoiceOver, the pin reads "Collapse to bubble" and the circle reads its open-task count and can be activated.

## Must pass

```sh
# BUILD from CLAUDE.md, then the sandbox check from ../phase0/T4-sandbox.md, then:
grep -q 'var openCount' MinimaList/Model/TaskStore.swift || echo "FAIL: no TaskStore.openCount"
grep -qF 'Collapse to bubble' MinimaList/Views/ContentView.swift || echo "FAIL: pin button has no label"
grep -q 'isCollapsed' MinimaList/Views/ContentView.swift && echo "FAIL: collapsed state belongs to FloatingWidget"
grep -rnE '@AppStorage|@SceneStorage|UserDefaults|forKey:|setFrameAutosaveName' MinimaList/Views/ MinimaList/Platform/ \
  | grep -v 'UserDefaults(suiteName: "preview-' && echo "FAIL: collapsed state and position must not be persisted"
grep -rn 'repeatForever' MinimaList/ && echo "FAIL: no looping motion"
# then TEST from CLAUDE.md.
```

The block prints nothing when the task passes.

## Do not

- Remember the collapsed state or the window position between launches (README out of scope).
- Open a second window or `NSPanel` for the bubble; the floating window swaps its content (design §11).
- Animate the collapse or expand.
- Show a badge or count on the menu-bar icon.
- Add the microphone (P3-T3).
