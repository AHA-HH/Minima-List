# Minima-List — macOS To‑Do Widget Design

**Status:** MVP design
**Platform:** macOS 14+
**Audience:** One person who wants a small, local task list that stays close to their work
**Product type:** Floating desktop widget with a menu-bar icon (menu bar from Phase 3)

## 1. Product summary

Little List is a calm, always-nearby to-do widget for macOS. It is designed to reduce the friction between noticing a task and recording it: the list should remain available while the user works, without requiring a full productivity app, account, or cloud sync.

The reference reel describes the motivating problem well: if a person has to remember to open the app that is supposed to help them remember, the tool has created unnecessary work. Little List addresses that problem with a compact floating window that can be opened quickly, left visible across Spaces, and used with a single-line input.

Reference: [Instagram reel](https://www.instagram.com/reel/DevKEHJRAzh/)

## 2. Problem statement

Most task apps optimize for comprehensive planning. That is useful when the user is intentionally planning, but it adds friction for small tasks that appear during the day. The user needs a lightweight capture surface that:

- is visible or immediately reachable while other apps are open;
- accepts a task in one short interaction;
- keeps the list readable at a glance;
- supports a small amount of organization without becoming a project-management system;
- works completely offline and locally.

## 3. Goals

### Primary goals

1. **Fast capture:** Add a task in under five seconds using the keyboard.
2. **Low cognitive load:** Show only the task information needed to decide what to do next.
3. **Persistent presence:** Keep the widget floating above other windows and available across Spaces and full-screen apps.
4. **Local-first storage:** Save tasks on the Mac without an account, network request, or remote dependency.
5. **Pleasant daily use:** Make the widget feel warm, quiet, and slightly playful rather than like an administrative dashboard.

### Secondary goals

- Make completion satisfying but unobtrusive.
- Let users distinguish broad areas of life without requiring detailed project setup.
- Provide sensible keyboard and accessibility behavior.
- Keep the codebase small enough to evolve quickly.

## 4. Non-goals for the MVP

- Cloud sync or multi-device collaboration
- Accounts, sign-in, or analytics
- Recurring tasks and reminders
- Calendar integration
- Due dates, estimates, subtasks, or dependencies
- Full menu-bar application behavior (planned for Phase 3, §8.6)
- Adding tasks by voice (planned for Phase 3, §8.8)
- Recreating the reference creator's exact visual design or assets

These can be considered after the core capture-and-complete loop is reliable.

## 5. Target user and key scenario

### Target user

A Mac user who keeps many small tasks in their head while writing, designing, coding, studying, or browsing. They want a visible scratchpad that is more structured than a sticky note but much lighter than a full task manager.

### Primary scenario

The user is working in another app and remembers: “reply to that email.” They press `⌘N`, type the task, press Return, and continue working. The widget remains available. Later, they click the task circle, see progress update, and move on without opening a separate workflow.

## 6. Product principles

### Stay where the work is

The widget should be available in the user's current context. It should not force a context switch for routine capture.

### One list, light structure

Categories should help scanning, not become a filing system. The MVP uses three broad categories: Focus, Life, and Later.

### Local by default

The user's task list is personal and should work without connectivity. Persistence should be dependable and transparent.

### Calm, not clinical

Use soft contrast, generous spacing, rounded shapes, and restrained motion. The interface can have personality without competing with the user's work.

### Completion is a state change, not a ceremony

Checking a task should be immediate. Progress feedback is useful, but celebrations, badges, and notifications are intentionally out of scope for the MVP.

## 7. Information architecture

The widget has one primary surface:

```text
Little List
├── Header
│   ├── App identity
│   ├── Time-aware greeting
│   ├── Current date
│   ├── Progress indicator
│   └── More actions
├── Task list
│   └── Task rows
└── Composer
    ├── New-task input
    ├── Category selector
    └── Keyboard hint
```

There are no separate screens in the MVP. Menu actions provide secondary controls without introducing navigation.

From Phase 3 the same widget appears in two places: the floating window and a drop-down panel under a menu-bar icon (§8.6). The floating window can also collapse to a small count bubble (§8.7), and the composer gains a microphone button (§8.8).

## 8. Core experience

### 8.1 Launch and presence

- Launch into a compact floating window.
- Hide the standard macOS title-bar controls to preserve the widget form.
- Allow the window to be dragged by its background.
- Keep the widget above normal windows.
- Join all Spaces and remain available alongside full-screen apps.
- Preserve the user's window position during the session. A later iteration may persist position between launches.
- From Phase 3: show no Dock icon and no app-switcher entry; the app lives in the menu bar (§8.6).

### 8.2 Add a task

1. Focus the composer by clicking it or pressing `⌘N`.
2. Type a short task title.
3. Optionally choose Focus, Life, or Later.
4. Press Return or click the add affordance.
5. Insert the new task at the top of the list.
6. Clear the input and return focus to it for rapid capture.

Validation:

- Ignore empty or whitespace-only input.
- Trim leading and trailing whitespace.
- Keep the task title as plain text.
- Do not block the user with a validation alert for normal input mistakes.

### 8.3 Complete a task

- Each row has a clearly visible circular toggle.
- Completing a task fills the circle, adds a checkmark, dims the title, and applies a strikethrough.
- Update the progress indicator immediately.
- Keep completed tasks visible by default so the state change is understandable.

### 8.4 Review and hide completed tasks

The overflow menu contains:

- **Hide completed / Show completed** — toggles completed-task visibility.
- **Clear completed** — removes all completed tasks after an explicit confirmation if the action is made destructive in a future UI iteration.
- **Quit Little List** — exits the app.

For the MVP, “Clear completed” may be direct because the operation is local and reversible only through re-entry; if the task count becomes meaningful, add an undo toast before shipping.

### 8.5 Delete a task

- Reveal a compact delete button on hover.
- Also expose Delete in the row context menu.
- Remove the task with a short fade/slide transition.
- Consider an undo affordance before adding bulk actions.

### 8.6 Menu bar (Phase 3)

- The app has no Dock icon and doesn't appear in the ⌘-Tab app switcher.
- A menu-bar icon is always present. Clicking it opens the widget as a drop-down panel under the icon; clicking elsewhere closes it.
- The panel and the floating window show the same list from the same `TaskStore`, so a task added in one appears in the other immediately.
- The `•••` menu gains **Show floating window / Hide floating window**, so the floating window can be brought back after it's closed. Quit stays in `•••`.
- `⌘N` still focuses the composer of whichever widget is in front.

### 8.7 Collapse to a count bubble (Phase 3)

- The floating window's header has a **pin** button next to `•••`.
- Pressing it collapses the floating window to a small circle (about 56 pt) that shows the number of open (not completed) tasks. The circle keeps floating above other windows, follows you across Spaces and can be dragged.
- Clicking the circle expands the full widget again in the same place.
- The count updates as tasks are added and completed. With no open tasks the circle shows a check mark instead of `0`.
- Collapsed or expanded is session state, like the other view state in §10; it isn't remembered between launches.

### 8.8 Add a task by voice (Phase 3)

1. Click the microphone button in the composer.
2. The first time, macOS asks for permission to use the microphone and speech recognition.
3. Speak the task. The words appear in the composer as you speak.
4. When you pause for about 1.5 seconds, listening stops and the task is added automatically with the selected category, exactly as if you had pressed Return.
5. Clicking the microphone again, or pressing Escape, cancels without adding anything.

Rules:

- Recognition runs on the Mac only (on-device). Audio and text never leave the Mac, which keeps the local-only rule (§6).
- If on-device recognition isn't available for the system language, or permission is denied, the microphone button is disabled and its help text says why.
- An empty or whitespace-only result adds nothing, following §8.2 validation.
- While listening, the button shows a steady "recording" state. It doesn't pulse or loop (§9 Motion).
- One utterance adds one task.

## 9. Visual design

### Overall direction

The visual direction takes inspiration from the reel's small, personal task surface: a list that feels like a friendly object on the desktop, not a corporate productivity tool. The implementation should be original and use its own typography, icons, layout, and color system.

### Layout

- Recommended default size: **380 × 610 pt**.
- Outer corner radius: **22 pt**.
- Horizontal content padding: **16–24 pt** depending on section.
- Task-row radius: **14 pt**.
- Use clear vertical grouping: header, list, composer.
- Let the task list scroll while the header and composer remain fixed.

### Wireframes

Low-fidelity layout at the default 380 × 610 pt size. Proportions are approximate; the measurements above take precedence.

**Main widget (default state)**

```text
┌──────────────────────────────────────────┐
│ LITTLE LIST                          ••• │ ← overflow menu (§8.4)
│                                          │
│ Good afternoon                           │ ← time-aware greeting
│ Monday, 26 October                       │ ← current date
│                                          │
│ ███████████████░░░░░░░░░░░░  2 of 5 done │ ← progress (coral)
├──────────────────────────────────────────┤ ─┐
│ ╭──────────────────────────────────────╮ │  │
│ │ ○  Reply to that email               │ │  │
│ │    ● Focus                           │ │  │
│ ╰──────────────────────────────────────╯ │  │
│ ╭──────────────────────────────────────╮ │  │
│ │ ○  Book dentist appointment for the  │ │  │ scrolls;
│ │    week after next                ✕  │ │  │ ✕ shows on hover
│ │    ● Life                            │ │  │
│ ╰──────────────────────────────────────╯ │  │
│ ╭──────────────────────────────────────╮ │  │
│ │ ✓  B̶u̶y̶ ̶o̶a̶t̶ ̶m̶i̶l̶k̶                      │ │  │ completed: filled,
│ │    ● Life                            │ │  │ dimmed, struck
│ ╰──────────────────────────────────────╯ │  │
│                  ⋮                       │  │
├──────────────────────────────────────────┤ ─┘
│ ╭──────────────────────────────────╮ ╭─╮ │
│ │ Add a task…                      │ │+│ │ ← composer (⌘N focuses)
│ ╰──────────────────────────────────╯ ╰─╯ │
│ [● Focus]  [ Life ]  [ Later ]           │ ← category selector
│ Return to add · ⌘N to focus              │ ← keyboard hint
└──────────────────────────────────────────┘
```

**Empty state** (no tasks, or all completed tasks hidden)

```text
├──────────────────────────────────────────┤
│                                          │
│                    ○                     │
│             Nothing here yet.            │
│          What's one thing to do?         │
│                                          │
├──────────────────────────────────────────┤
```

**Overflow and row context menus**

```text
                          ┌────────────────────┐
  ••• →                   │ Hide completed     │
                          │ Clear completed    │
                          │────────────────────│
                          │ Quit Little List ⌘Q│
                          └────────────────────┘

                          ┌────────────────────┐
  right-click a row →     │ Mark complete      │  (or "Reopen")
                          │────────────────────│
                          │ Delete             │
                          └────────────────────┘
```

**Phase 3 additions** (§8.6–§8.8)

```text
 menu bar:  … ☰✓ …        ← menu-bar icon; click opens the widget as a drop-down panel

┌──────────────────────────────────────────┐
│ MINIMA LIST                       📌 ••• │ ← pin collapses the floating window
│ …                                        │
│ ╭──────────────────────────────╮ ╭─╮ ╭─╮ │
│ │ Add a task…                  │ │🎙│ │+│ │ ← microphone: speak, pause, task is added
│ ╰──────────────────────────────╯ ╰─╯ ╰─╯ │
└──────────────────────────────────────────┘

   ╭───╮
   │ 3 │   ← collapsed: open-task count; click to expand
   ╰───╯
```

### Color tokens

| Token | Purpose | Direction |
| --- | --- | --- |
| `widgetBackground` | Main surface | Deep charcoal with a subtle purple cast |
| `surfaceRaised` | Task rows and input | White at low opacity over the background |
| `textPrimary` | Active task titles | Near-white |
| `textSecondary` | Dates, hints, metadata | White at reduced opacity |
| `accentCoral` | Primary action and progress | Warm coral/orange |
| `categoryFocus` | Focus category | Coral |
| `categoryLife` | Life category | Soft blue |
| `categoryLater` | Later category | Muted violet |

The palette should remain legible in both bright and dim desktop environments. Do not rely on color alone to communicate task state; pair color with shape, icon, text treatment, or position.

### Typography

- Use the system rounded design where available for a friendly, compact feel.
- App label: small, bold, tracked uppercase text.
- Greeting: large semibold text.
- Task title: medium weight, readable at a glance, two-line maximum.
- Metadata and hints: small but never below a comfortable accessibility size without respecting Dynamic Type-like scaling.

### Motion

- Use a short spring when toggling completion.
- Fade the hover delete control in and out.
- Use a brief ease-out removal transition.
- Avoid looping motion, confetti, or attention-seeking effects.

## 10. Functional requirements

### Task model

```swift
struct TaskItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var category: TaskCategory
    var isComplete: Bool
    var createdAt: Date
}
```

`TaskCategory` is an enum with the MVP values `focus`, `life`, and `later`. Categories should own their display label, color, and symbol so the view layer does not duplicate presentation rules.

### Persistence

- Store the task array locally using `UserDefaults` encoded as JSON for the MVP.
- Load saved tasks during app initialization.
- Save after every mutation through the store's single source of truth.
- If stored data cannot be decoded, fall back to an empty or example state without crashing.
- Keep persistence behind `TaskStore` so it can later be replaced with a file-backed store, SwiftData, or iCloud without changing the views.

### State ownership

`TaskStore` owns task data and derived values:

- `tasks`
- `completedCount`
- `progress`
- add, toggle, remove, and clear-completed operations

`ContentView` owns transient UI state:

- composer text
- selected category
- completed-task visibility
- input focus

## 11. macOS behavior and technical approach

- Build with SwiftUI for the interface and AppKit interop for window configuration.
- Target macOS 14 or later.
- Use a `WindowGroup` with content-sized behavior.
- Configure the underlying `NSWindow` to be transparent, movable by background, floating, and visible across Spaces.
- Keep the app local and offline; no network permission is needed.
- Support the standard macOS quit action and `⌘N` for new-task focus.

From Phase 3:

- Run as an accessory app with no Dock icon (`LSUIElement`, set through the generated Info.plist's `INFOPLIST_KEY_LSUIElement`).
- Add the menu-bar icon and its drop-down panel with SwiftUI `MenuBarExtra` using `.menuBarExtraStyle(.window)` (macOS 13+), hosting the same widget view and `TaskStore` as the floating window.
- Collapse the floating window by swapping its content for the count bubble. The window follows its content size (`.windowResizability(.contentSize)`), keeping its top-left corner where it was.
- Use Apple's Speech framework with `requiresOnDeviceRecognition = true`, fed by `AVAudioEngine`. This needs the sandbox's microphone entitlement (`com.apple.security.device.audio-input`) and the `NSMicrophoneUsageDescription` and `NSSpeechRecognitionUsageDescription` Info.plist strings. No network entitlement is added.

Potential hardening for later (see §15 "Later"):

- Persist window frame and restore it safely when the display arrangement changes.
- Add a global hotkey only if the menu bar and floating window aren't enough.
- Move from `UserDefaults` to a versioned local store if task history or migrations are introduced.

## 12. Accessibility requirements

- Every interactive control must have a meaningful accessibility label.
- The task toggle label should include the task title and state, e.g. “Mark reply to email complete.”
- The hover-only delete affordance must also be reachable through the context menu and keyboard navigation.
- Maintain visible focus indication for the composer and category controls.
- Do not encode category meaning through color alone; expose the category name as text.
- Respect Reduce Motion where practical by shortening or removing spring animations.
- Verify the widget with VoiceOver and keyboard-only navigation before release.

## 13. Empty, error, and edge states

| Situation | Expected behavior |
| --- | --- |
| No tasks | Show a quiet empty state with an invitation to add one thing |
| All tasks completed | Keep completed rows visible unless the user hides them; show 100% progress |
| Completed tasks hidden | Show the empty state if nothing remains visible |
| Very long title | Wrap to two lines and keep row controls aligned |
| Rapid repeated Return presses | Avoid duplicate empty tasks; each non-empty submission creates one task |
| Corrupt local data | Recover to a safe empty/example state and continue running |
| Many tasks | Keep scrolling smooth; avoid expanding the window beyond the intended widget footprint |
| Dark/light system appearance | Preserve the product's dark surface while maintaining contrast and legibility |

## 14. MVP acceptance criteria

The MVP is ready when:

- The app launches into a floating 380 × 610 pt widget.
- The widget can be dragged by its background.
- It remains available across Spaces and full-screen apps.
- A user can add a task with text input and Return.
- Empty input is ignored.
- A user can choose one of the three categories before adding a task.
- Tasks persist after quitting and relaunching.
- A task can be completed and reopened.
- Completion updates the count and progress indicator immediately.
- Completed tasks can be shown or hidden.
- A task can be deleted by hover action or context menu.
- `⌘N` focuses the new-task input.
- The core flow is usable with keyboard navigation and VoiceOver labels.

## 15. Phased implementation plan

Each phase ends with an app that builds and runs. Tasks have stable IDs (`P<phase>-T<task>`) so they can be tracked, briefed, and reviewed one at a time. A phase is complete only when all of its exit criteria pass on a clean build.

```text
P0 Scaffold ──► P1 Core loop ──► P2 Daily usability ──► P3 Menu bar & voice
                 │                      │
                 └─ MVP shell           └─ MVP complete (all §14 criteria)
```

### Phase 0 — Project scaffold

**Goal:** an empty window builds, runs, and has a test target. The repository currently contains no source code (see §17). Task briefs: [`docs/mvp/phase0/`](../mvp/phase0/README.md).

- [x] **P0-T1** Create the Xcode macOS App project `MinimaList`: SwiftUI lifecycle, macOS 14 deployment target, unit-test target `MinimaListTests`.
- [x] **P0-T2** Set the source layout (`Model/`, `Views/`, `Platform/`) and write `CLAUDE.md` with the build/test commands and repo rules.
- [x] **P0-T3** Add an Xcode `.gitignore` covering `xcuserdata/`, `DerivedData/`, and `.DS_Store`.
- [x] **P0-T4** Keep App Sandbox enabled with no network entitlement, so the app stays local-only.
- [x] **P0-T5** Set up Zed for day-to-day editing (`sourcekit-lsp` via `xcode-build-server`). No step needs the Xcode GUI; P0-T1 writes the project file as text.

**Exit criteria:** `xcodebuild build` and `xcodebuild test` succeed from the command line; the app launches to a blank window.

### Phase 1 — Core loop

**Goal:** in the floating widget shell, tasks can be added, completed, and deleted, and they survive a relaunch. Task briefs: [`docs/mvp/phase1/`](../mvp/phase1/README.md).

| ID | Task | File(s) | Depends on |
| --- | --- | --- | --- |
| P1-T1 | `TaskItem` model and `TaskCategory` enum, where `TaskCategory` owns its label, color, and SF Symbol | `Model/TaskItem.swift` | P0 |
| P1-T2 | `TaskStore` (`@Observable`): `tasks`, `completedCount`, `progress`, `add`, `toggle`, `remove`, `clearCompleted`; JSON persistence to an injected `UserDefaults`; decode failure → empty list | `Model/TaskStore.swift` | P1-T1 |
| P1-T3 | `WindowConfigurator`: transparent background, movable by background, `.floating` level, `[.canJoinAllSpaces, .fullScreenAuxiliary]`, hidden traffic lights | `Platform/WindowConfigurator.swift` | P0 |
| P1-T4 | `ContentView` shell: header, scrolling list, and composer per the wireframe; 380 × 610 pt, 22 pt radius, color tokens; app owns the store | `Views/ContentView.swift`, `Views/Theme.swift`, `Views/Greeting.swift`, `MinimaListApp.swift` | P1-T2, P1-T3, P1-T5 |
| P1-T5 | `TaskRow`: toggle circle, two-line title, delete button on hover | `Views/TaskRow.swift` | P1-T1 |
| P1-T6 | Empty state | `Views/ContentView.swift` | P1-T4 |

- [x] P1-T1 · [x] P1-T2 · [x] P1-T3 · [x] P1-T4 · [x] P1-T5 · [x] P1-T6

**Unit tests (`TaskStoreTests`):**

- `add` trims whitespace and ignores empty or whitespace-only titles.
- `add` inserts the new task at the top.
- `toggle` flips `isComplete`; `remove` deletes only the target.
- `progress` is `0` with no tasks (no divide-by-zero) and `1` when all tasks are complete.
- Save → new store on the same `UserDefaults` suite → tasks are equal.
- Corrupt bytes in the stored key → the store loads empty and does not crash.

**Exit criteria (from §14):** launches as a floating 380 × 610 pt widget · draggable by background · visible across Spaces and over a full-screen app · add with Return · empty input ignored · persists across quit and relaunch · complete and reopen · progress updates immediately · delete on hover.

### Phase 2 — Daily usability

**Goal:** close the remaining §14 criteria. This completes the MVP. Task briefs: [`docs/mvp/phase2/`](../mvp/phase2/README.md).

- [x] **P2-T1** Category selector in the composer (default: Focus). Rows show the category as text plus color, never color alone.
- [x] **P2-T2** Overflow menu: Hide/Show completed, Clear completed, Quit.
- [x] **P2-T3** Row context menu: Mark complete/Reopen, Delete.
- [x] **P2-T4** `⌘N` command that focuses the composer (`.commands` + `@FocusState`). It replaces `WindowGroup`'s New Window command, which otherwise opens a second widget on `⌘N`.
- [x] **P2-T5** Motion: spring on toggle, fade on hover delete, ease-out on removal. With Reduce Motion enabled, motion is shortened or removed.
- [x] **P2-T6** Accessibility pass against §12: labels on every control, a keyboard-only walkthrough, and a VoiceOver walkthrough.

**Unit tests:** `clearCompleted` removes only completed tasks. With completed tasks hidden, the visible list is empty when every task is complete, which triggers the empty state.

**Exit criteria (from §14):** category chosen before adding · completed tasks shown/hidden · delete via context menu · `⌘N` focuses input · core flow works keyboard-only and with VoiceOver.

### Phase 3 — Menu bar and voice

**Goal:** Minima List lives in the menu bar with no Dock icon, the floating window can collapse to a count bubble, and a task can be added by speaking. Task briefs: [`docs/mvp/phase3/`](../mvp/phase3/README.md).

- [x] **P3-T1** Menu-bar app (§8.6): no Dock icon (`LSUIElement`), a `MenuBarExtra` icon whose drop-down panel shows the same widget and store, and Show/Hide floating window in `•••`. `⌘N` moved from the File menu onto the widget's `Return to add · ⌘N to focus` hint button (risk table below).
- [x] **P3-T2** Pin and collapse (§8.7): a pin button collapses the floating window to a floating circle with the open-task count; clicking the circle expands it in place. While collapsed the window drops `.titled` (risk table below).
- [x] **P3-T3** Voice capture (§8.8): a microphone button records with on-device speech recognition, shows the words in the composer, and adds the task automatically after about 1.5 s of silence.

**Unit tests:** the open-task count and its bubble text (a check mark at zero); the end-of-speech rule (a pause of the threshold after speech ends listening, and a pause before any speech doesn't); a transcript becomes a task only when it's non-empty after trimming.

**Exit criteria:** no Dock icon and a working menu-bar panel that stays in sync with the floating window · the floating window can be hidden, shown again, collapsed and expanded · a spoken task is added automatically after a pause, with nothing sent off the Mac · the new controls have VoiceOver labels and respect Reduce Motion.

### Later (not planned)

These were the original Phase 3 ideas. They stay here as candidates, not commitments:

- Persist the window frame between launches. On restore, clamp it to a visible screen so a disconnected display can't strand the widget off-screen.
- Version the stored payload (`{ "version": 1, "tasks": [...] }`) and migrate from the Phase 1 bare-array format.
- Undo for Delete and Clear completed, via a ⌘Z `UndoManager` or a short undo toast.
- Use the app for one week of real work and log every point of friction.
- Tune the default size, copy, and spacing. Check that `textSecondary` on `widgetBackground` meets 4.5:1 contrast.
- Resolve each §16 open question, or defer it with a recorded reason.

### Technical risks to check early

| Risk | Why it matters | Check in | Fallback |
| --- | --- | --- | --- |
| A `WindowGroup` window may not appear over full-screen apps | Breaks the "persistent presence" goal | P1-T3 | Host the view in an `NSPanel` with `.nonactivatingPanel` |
| A borderless window can refuse key status, so the text field can't take focus | Breaks typing into the composer | P1-T3 / P1-T4 | Keep `.titled` with `titlebarAppearsTransparent` and `.fullSizeContentView` instead of `.borderless`. **Exception (owner, 2026-10-30):** the collapsed count bubble (P3-T2) drops `.titled`, because a titled window draws a rounded-square outline and shadow around the circle; expanding restores it. The bubble then can't be reached with Full Keyboard Access, but mouse and VoiceOver work. |
| Hover-only delete is unreachable by keyboard | Accessibility requirement (§12) | P2-T6 | The context menu and a focusable delete control cover it |
| An accessory app (no Dock icon) shows no main menu bar, so `⌘N` and `⌘Q` may stop firing | Breaks P2-T4's shortcut | P3-T1 | Keep Quit in `•••` and the panel; move `⌘N` onto a visible in-widget control's `.keyboardShortcut`. **Applied in P3-T1:** the panel's scene never reached app commands, so `⌘N` is on the composer's hint button. |
| An accessory app's windows may not become key on first click, so the composer can't take typing | Breaks capture | P3-T1 | Activate the app (`NSApp.activate`) when the panel or floating window is clicked |
| On-device speech recognition isn't available for every language or Mac | Voice capture can't stay local | P3-T3 | Disable the microphone with an explanation; never fall back to server recognition |

## 16. Open questions

1. Should the widget launch automatically at login, or should that remain opt-in?
2. Should completed tasks remain visible for the whole day, or should they be archived automatically?
3. Is a floating window enough, or is a menu-bar/global-hotkey entry point needed after real-world testing? **Answered (owner, 2026-10-28):** both a menu-bar icon and the floating window, with no Dock icon (Phase 3). A global hotkey is still not planned.
4. Should categories be renamed or user-configurable, or do three fixed buckets keep the experience calmer?
5. Should the app remember the last selected category between launches?

## 17. Implementation notes for the current prototype

The current workspace already contains a SwiftUI/AppKit prototype with the main MVP pieces:

- `TaskItem` and `TaskStore` for the model and local persistence
- `ContentView` for the header, task list, and composer
- `TaskRow` for completion, hover delete, and context-menu behavior
- `WindowConfigurator` for the floating macOS window behavior

The next implementation priority should be validation rather than expanding scope: compile and run the app, test persistence across relaunches, verify the floating-window behavior across Spaces, and complete the accessibility pass.
