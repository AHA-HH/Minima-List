# P1-T3 — Floating window

**Phase:** [1 — Core loop](README.md)
**Design reference:** §8.1 (launch and presence), §11 (window configuration), §15 "Technical risks to check early"
**Depends on:** Phase 0

## Goal

Make the app's window behave like a widget: it floats above normal windows, joins every Space and full-screen apps, drags by its background, and has no visible title bar or traffic lights, while still accepting keyboard input.

## Files

- `MinimaList/Platform/WindowConfigurator.swift` (new)
- `MinimaList/MinimaListApp.swift` (attach the configurator)
- `MinimaListTests/WindowConfiguratorTests.swift` (new)

## Steps

1. In `WindowConfigurator.swift` (`import AppKit` and `import SwiftUI`), write `enum WindowConfigurator` with `@MainActor static func configure(_ window: NSWindow)` that sets:
   - `isOpaque = false`, `backgroundColor = .clear`, `hasShadow = true`
   - `isMovableByWindowBackground = true`
   - `level = .floating`
   - `collectionBehavior` includes `.canJoinAllSpaces` and `.fullScreenAuxiliary`
   - `titlebarAppearsTransparent = true`, `titleVisibility = .hidden`, and `styleMask` gains `.fullSizeContentView`
   - the close, miniaturize and zoom buttons (`standardWindowButton(_:)`) are hidden

   Keep `.titled` in the style mask. **Don't** switch to `.borderless`: a borderless window can refuse key status, and the composer's text field would stop taking typing (design §15 risk table).
2. In the same file, add a SwiftUI bridge: a `struct WindowAccessor: NSViewRepresentable` whose `NSView` subclass overrides `viewDidMoveToWindow()` and calls `WindowConfigurator.configure(_:)` when `window` is non-nil. No timers and no `DispatchQueue.main.async` guessing.
3. In `MinimaListApp.swift`, attach it: `ContentView().background(WindowAccessor())`. Change nothing else in the app file (P1-T4 adds the store and size).
4. Manual check on your own Mac before opening the PR: build, run, and try each manual check below. If the window doesn't float over a full-screen app, **stop and report it**. The fallback (an `NSPanel`) is a design decision for the owner, not part of this task.

## Tests that define done

In `WindowConfiguratorTests.swift` (Swift Testing, `@MainActor`): create a plain `NSWindow(contentRect:styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: true)`, call `WindowConfigurator.configure(_:)`, and assert every setting in step 1, including that `.titled` is still in the style mask and each of the three standard buttons is hidden.

Manual checks (owner; record results in the review):

- The window has no title bar or traffic lights, and dragging its background moves it.
- It stays above other apps' windows when you click into them.
- It's still visible after switching to another Space, and on top of a full-screen app.

## Must pass

```sh
# BUILD and TEST from CLAUDE.md, then the sandbox check from ../phase0/T4-sandbox.md right after a BUILD.
grep -n 'borderless' MinimaList/Platform/WindowConfigurator.swift && echo "FAIL: borderless style"
grep -n 'DispatchQueue\|asyncAfter\|Timer' MinimaList/Platform/WindowConfigurator.swift && echo "FAIL: timing hack"
```

The block prints nothing when the task passes.

## Do not

- Use `NSPanel`, `.borderless`, a menu-bar item or a global hotkey (design §11 defers the last two).
- Persist or restore the window frame (Phase 3).
- Set the window size here; P1-T4 sizes the content.
- Touch `ContentView` or anything in `Model/`.
