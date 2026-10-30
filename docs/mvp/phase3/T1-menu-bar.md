# P3-T1 — Menu-bar app

**Phase:** [3 — Menu bar and voice](README.md)
**Design reference:** §8.6 (menu bar), §8.1 (no Dock icon from Phase 3), §11 (`MenuBarExtra` with `.window` style), §15 technical risks (accessory app shortcuts and key status)
**Depends on:** P2 (signed off)

## Goal

Minima List has no Dock icon and no ⌘-Tab entry. A menu-bar icon opens the same widget as a drop-down panel, using the one `TaskStore`. The `•••` menu can hide the floating window and show it again.

## Files

- `MinimaList.xcodeproj/project.pbxproj` (one build setting on the `MinimaList` target, Debug and Release)
- `MinimaList/MinimaListApp.swift` (edit)
- `MinimaList/Views/ContentView.swift` (edit)
- `MinimaList/Platform/` (new file only if the key-status check in step 6 fails)

## Steps

1. In the `MinimaList` target's Debug and Release configurations, set `INFOPLIST_KEY_LSUIElement = YES`. The target already uses `GENERATE_INFOPLIST_FILE = YES`, so don't add an `Info.plist` file. Don't call `NSApp.setActivationPolicy` in code: the build setting is the single source of truth.
2. In `MinimaListApp`, change `WindowGroup` to `Window("Minima List", id: "widget")`. A `Window` scene has exactly one instance, so `openWindow(id: "widget")` brings the existing window forward and never opens a second one. Keep `.windowStyle(.hiddenTitleBar)`, `.windowResizability(.contentSize)`, `WindowAccessor` and the `CommandGroup(replacing: .newItem)` command.
3. Add a second scene after the window:
   ```swift
   MenuBarExtra("Minima List", systemImage: "checklist") {
       ContentView(store: store, isFloatingWindowShown: isFloatingWindowShown)
   }
   .menuBarExtraStyle(.window)
   ```
   Pass the same `store`, because `CLAUDE.md` makes `TaskStore` the only owner of task data. Don't wrap the panel's `ContentView` in `WindowAccessor`, because the panel is not a floating widget.
4. Track whether the floating window is open with `@State private var isFloatingWindowShown = true` in `MinimaListApp`. The floating window's content sets it to `true` in `.onAppear` and to `false` in `.onDisappear`. Pass the value to both `ContentView`s.
5. In `ContentView`:
   - Add `let isFloatingWindowShown: Bool` and read `@Environment(\.openWindow)` and `@Environment(\.dismissWindow)`.
   - In the `•••` menu, above the `Divider()` before Quit, add `Hide floating window` when `isFloatingWindowShown` is true, which calls `dismissWindow(id: "widget")`, or `Show floating window` when it is false, which calls `openWindow(id: "widget")`.
   - Update `#Preview` to pass `isFloatingWindowShown: true`.
6. Check the two accessory-app risks from the README before adding anything else, and record each result in the PR:
   - **Shortcuts.** With the app active, does `⌘N` still focus the composer and `⌘Q` still quit? If `⌘N` stops working, move `.keyboardShortcut("n")` onto a visible in-widget control, as the README's fallback says. Quit already lives in `•••`.
   - **Key status.** Does the first click in the floating window or the panel let you type in the composer straight away? If not, add `NSApp.activate()` (macOS 14) in a small helper in `MinimaList/Platform/` and call it when the widget is clicked. Don't use the deprecated `activate(ignoringOtherApps:)`.
7. Check that hiding the floating window does **not** quit the app. A SwiftUI app whose only scene is a `Window` quits when the window closes, but the `MenuBarExtra` should keep it running. If it quits, report it; don't work around it with an `NSApplicationDelegate` before the owner decides.

## Tests that define done

- `TEST` passes. There's no new unit test: everything here is scene wiring that only a running app shows. Every existing test still passes after the `ContentView` initializer change.

Runtime probe (throwaway, README convention), reported in the PR:

- Log `NSApp.activationPolicy() == .accessory`.
- Log `NSApp.windows.filter(\.isVisible).count` after launch, and again after triggering the File menu's New Task item twice. Both must count one widget window. The status-bar window is not a widget window, so say how you told them apart.
- Open the panel by finding the status item's button in `NSApp.windows` and calling `performClick(nil)`, then render the panel window to a PNG. If you can't reach the button, say so and leave the panel image to the owner.
- A PNG of the floating window, which must look exactly as it did before this task. `cacheDisplay` can't capture an open menu, so log the `•••` menu's item titles instead of imaging it.

Manual checks (owner):

- No Dock icon and no ⌘-Tab entry. The menu-bar icon opens the widget under it; clicking elsewhere closes it.
- A task added in the panel appears in the floating window at once, and the other way round.
- `•••` › Hide floating window closes it; the app keeps running. Panel › `•••` › Show floating window brings it back, and the floating window's position is wherever macOS puts a newly opened window.
- `⌘N` focuses the composer of the widget in front and never opens a second window. Quit Minima List still quits.

## Must pass

```sh
# BUILD from CLAUDE.md, then the sandbox check from ../phase0/T4-sandbox.md, then:
APP=$(xcodebuild -project MinimaList.xcodeproj -scheme MinimaList -showBuildSettings 2>/dev/null \
  | awk -F' = ' '/ BUILT_PRODUCTS_DIR = /{d=$2} / FULL_PRODUCT_NAME = /{n=$2} END{print d"/"n}')
/usr/libexec/PlistBuddy -c 'Print :LSUIElement' "$APP/Contents/Info.plist" 2>/dev/null | grep -qx true || echo "FAIL: LSUIElement not set"
grep -q 'MenuBarExtra' MinimaList/MinimaListApp.swift || echo "FAIL: no MenuBarExtra"
grep -q '\.menuBarExtraStyle(\.window)' MinimaList/MinimaListApp.swift || echo "FAIL: panel is not window style"
grep -q 'WindowGroup' MinimaList/MinimaListApp.swift && echo "FAIL: WindowGroup can open a second widget"
test "$(grep -rhoF 'TaskStore()' MinimaList/ | wc -l | tr -d ' ')" = 1 || echo "FAIL: the app must create exactly one TaskStore"
grep -rn 'setActivationPolicy' MinimaList/ && echo "FAIL: use LSUIElement, not code"
for s in "Hide floating window" "Show floating window"; do
  grep -qF "$s" MinimaList/Views/ContentView.swift || echo "FAIL: missing menu item: $s"
done
# then TEST from CLAUDE.md.
```

The block prints nothing when the task passes.

## Do not

- Create a second `TaskStore`, or pass tasks to the panel any other way than the shared store.
- Add a badge, count or second layout to the menu-bar icon (README out of scope).
- Add a global hotkey or launch at login.
- Persist whether the floating window is shown, or its position.
- Add an `NSApplicationDelegate`, `NSStatusItem` or `NSMenu`; `MenuBarExtra` covers this.
- Add the pin button or the microphone (P3-T2, P3-T3).
