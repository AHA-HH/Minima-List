# P1-T4 — Widget shell

**Phase:** [1 — Core loop](README.md)
**Design reference:** §7 (information architecture), §8.2 (add a task), §9 (layout, wireframe, color tokens, typography), §10 (state ownership)
**Depends on:** P1-T2, P1-T3, P1-T5

## Goal

Replace the template "Hello, world!" view with the real widget: a header with greeting, date and progress; a scrolling list of `TaskRow`s; and a composer that adds a task on Return. All of it is wired to one `TaskStore` owned by the app.

## Files

- `MinimaList/Views/ContentView.swift` (rewrite)
- `MinimaList/Views/Theme.swift` (new: the non-category color tokens)
- `MinimaList/Views/Greeting.swift` (new: time-of-day greeting)
- `MinimaList/MinimaListApp.swift` (own the store, fix the window size)
- `MinimaListTests/GreetingTests.swift` (new)
- `MinimaListTests/MinimaListTests.swift` (update the template smoke test for the new `ContentView` init)

## Steps

1. **Store ownership (design §10).** In `MinimaListApp`, hold `@State private var store = TaskStore()` and pass it: `ContentView(store: store)`. Keep P1-T3's `.background(WindowAccessor())`. Add `.windowResizability(.contentSize)` to the `WindowGroup`, so the window takes the content's fixed size.
2. **Theme.** In `Theme.swift`, add an `extension Color` with the §9 tokens that aren't category colors:
   - `widgetBackground`: deep charcoal with a purple cast, about `Color(red: 0.11, green: 0.10, blue: 0.13)`
   - `surfaceRaised`: `.white.opacity(0.06)`
   - `textPrimary`: `.white.opacity(0.92)`
   - `textSecondary`: `.white.opacity(0.55)`
   - `accentCoral`: reuse `TaskCategory.focus.color`, so coral is defined once
3. **Greeting.** In `Greeting.swift`, write `func greeting(for date: Date, calendar: Calendar = .current) -> String` returning `"Good morning"` for hours 5–11, `"Good afternoon"` for 12–17, and `"Good evening"` otherwise.
4. **`ContentView(store: TaskStore)`.** It owns only transient UI state (design §10): `@State` composer text and `@FocusState` input focus.
   - **Header:** `MINIMA LIST` (small, bold, tracked, uppercase; the one place the name appears), `greeting(for: .now)` (large semibold), today's date (`.dateTime.weekday(.wide).day().month(.wide)`), and a coral progress bar of `store.progress` with `"\(store.completedCount) of \(store.tasks.count) done"`.
   - **List:** `ScrollView` + `LazyVStack` of `TaskRow(task:onToggle:onDelete:)` over `store.tasks`, calling `store.toggle(task.id)` and `store.remove(task.id)`. Only the list scrolls; the header and composer stay fixed.
   - **Composer:** a `TextField("Add a task…")` on a `surfaceRaised` background, plus a `+` button. Return and `+` both call `store.add(title: text, category: .focus)`, clear the text, and keep focus in the field for the next task. Under it, the hint `Return to add`.
   - **Frame:** `.frame(width: 380, height: 610)`, `Color.widgetBackground` background, clipped to a 22 pt continuous rounded rectangle. Rounded system font design throughout.
   - `#Preview`: a store on a throwaway `UserDefaults(suiteName:)` with a few sample tasks.
5. **No invisible strip above the widget.** A titled SwiftUI window reserves about 32 pt above the content for its (hidden) title bar, so a 380 × 610 frame gives a 380 × 642 window. The strip is invisible on a clear background but still catches clicks and drags. The P1-T3 review found that `.ignoresSafeArea()` on `ContentView` and `.windowStyle(.hiddenTitleBar)` on their own don't remove it. Make the **window** exactly 380 × 610. Keep any fix inside `MinimaListApp.swift` or `Platform/WindowConfigurator.swift` (and extend its unit test if you change `configure`). Don't switch to `.borderless` or `NSPanel`. If it can't be done on macOS 14, stop and report what you tried.
6. **Template test.** Update `MinimaListTests.swift` so it builds `ContentView(store:)` with an isolated-defaults store.

## Tests that define done

- `GreetingTests.swift` (Swift Testing), using a fixed `Calendar` and dates built from date components:
  - 05:00 and 11:59 → morning
  - 12:00 and 17:59 → afternoon
  - 18:00, 23:59, 00:00 and 04:59 → evening
- The updated smoke test constructs `ContentView(store:)` and passes.
- **Measured window size.** Launch the built app and read its window bounds with `CGWindowListCopyWindowInfo`: the on-screen MinimaList window is `380 × 610` and its layer is still `3`. Record the numbers in the PR. Quit the app afterwards.
- Every P1-T1, P1-T2, P1-T3 and P1-T5 test still passes.

Manual checks (owner; record results in the review):

- The widget is 380 × 610 pt with rounded corners and no square corners showing, and clicking just above its top edge reaches the app behind it (no invisible strip).
- Typing "reply to email" and pressing Return adds it at the top and leaves the cursor in the field. Typing only spaces and pressing Return adds nothing.
- Toggling a row updates the progress bar and the "n of m done" text immediately.
- With enough tasks to overflow, only the list scrolls.
- Quit (⌘Q) and relaunch: the same tasks come back with the same completion states.

## Must pass

```sh
# BUILD and TEST from CLAUDE.md, then the sandbox check from ../phase0/T4-sandbox.md right after a BUILD.
grep -n 'Hello, world' MinimaList/Views/ContentView.swift && echo "FAIL: template view still present"
grep -rn 'UserDefaults' MinimaList/Views/ | grep -v 'suiteName' && echo "FAIL: views must not persist directly"
grep -c '"MINIMA LIST"' MinimaList/Views/ContentView.swift | grep -qx 1 || echo "FAIL: app name should appear exactly once"
```

The block prints nothing when the task passes.

## Do not

- Add the category selector, overflow menu, hide/clear completed UI, `⌘N`, or animations (phase README, out of scope).
- Mutate tasks anywhere except through `TaskStore` methods.
- Read `UserDefaults` in views, except to build an isolated store in `#Preview`.
- Create a second `TaskStore` in the app.
