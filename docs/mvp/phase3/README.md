# Phase 3 — Menu bar and voice

**Objective:** Minima-List after the MVP ([design document](../../design/Minima-List.md), §15)
**Goal:** Minima List lives in the menu bar with no Dock icon, the floating window can collapse to a small count bubble, and a task can be added by speaking (design §8.6–§8.8).
**Starting point:** Phase 2 is complete and signed off by the owner, so the MVP is done. `main` has the floating 380 × 610 widget with categories, the `•••` menu (Hide/Show completed, Clear completed, Quit), row context menus, `⌘N`, motion with Reduce Motion, and the accessibility pass. There are 32 tests in 9 suites. The app shows a Dock icon, has no menu-bar icon, and has only the sandbox entitlement.

## Tasks

Each task edits `ContentView.swift`, and T1 and T3 both change the app target's build settings, so they run one after another.

| Wave | ID | Brief | Depends on |
| --- | --- | --- | --- |
| 1 | P3-T1 | [Menu-bar app](T1-menu-bar.md) | P2 |
| 2 | P3-T2 | [Pin and collapse to a count bubble](T2-pin-bubble.md) | P3-T1 |
| 3 | P3-T3 | [Voice capture](T3-voice-capture.md) | P3-T2 |

- [x] P3-T1 · [x] P3-T2 · [x] P3-T3

Tick an item only after both reviews pass (the thermo-nuclear code quality review and the `reviewer` agent) and the PR is merged.

## Shared commands

`BUILD` and `TEST` are defined in [`CLAUDE.md`](../../../CLAUDE.md) under **Checks**. Every task in this phase touches the app target, so run the sandbox check in [`../phase0/T4-sandbox.md`](../phase0/T4-sandbox.md) **right after `BUILD`**, never after `TEST`.

## Conventions for this phase

All Phase 1 and Phase 2 conventions still apply:

- Testable logic lives in plain or `static` functions.
- Tests use isolated `UserDefaults` suites.
- Every visual change gets a window PNG from a throwaway probe build.
- Transient UI state stays in the view.
- Menus are SwiftUI.

In addition:

- **One store, two widgets.** The menu-bar panel and the floating window both show `ContentView` with the one `TaskStore` owned by `MinimaListApp`. Never create a second store (`CLAUDE.md`: `TaskStore` is the only owner of task data).
- **Still local-only.** Speech recognition sets `requiresOnDeviceRecognition = true`. There is never a server fallback, and no networking code or network entitlement is added.
  - P3-T3 adds exactly one entitlement, `com.apple.security.device.audio-input`.
  - It adds two Info.plist strings, `NSMicrophoneUsageDescription` and `NSSpeechRecognitionUsageDescription`, which are set as `INFOPLIST_KEY_…` build settings.
  - Its brief extends the sandbox check so that any other entitlement fails.
- **Platform code goes in `Platform/`.** Audio and Speech framework code (`AVAudioEngine`, `SFSpeechRecognizer`) and any `NSApp` activation code belong in `MinimaList/Platform/`. Views call it through a small interface. The rule that decides when speech has ended is a plain function with unit tests.
- **No looping motion.** The recording state is steady, not pulsing. P2-T5's Must-pass check for `repeatForever` still applies.
- **Probe builds have no Dock icon after P3-T1.** A probe build's window still renders through `cacheDisplay`. But quit it from its `•••` menu or with `pkill -f probe.minimalist.<task>`, because it no longer appears in the Dock.
  - Never grant a probe microphone access by hand.
  - For P3-T3, probe only the permission-denied or unavailable path, and leave real speech to the owner.

## Out of scope for this phase

The reviewer flags these as scope violations:

- **Moved to "Later" in design §15:**
  - window-position persistence
  - data versioning or migration
  - undo
  - size and contrast tuning
  - resolving the other open questions
- **Keyboard and launch:**
  - a global hotkey that works while another app is active
  - launch at login
- **Speech:**
  - server-based speech recognition
  - wake words or always-on listening
  - adding several tasks from one utterance
  - voice commands such as "complete" or "delete"
  - choosing the category by voice
- **Bubble and menu-bar extras:**
  - remembering the collapsed state between launches
  - a badge or count on the menu-bar icon
  - a second, different menu-bar layout
- **Anything else:** a third-party dependency, or an entitlement other than `device.audio-input`.

## Technical risks

These come from design §15. Each task checks its own risks first and records the result in its PR.

| Risk | Check in | Fallback |
| --- | --- | --- |
| An accessory app shows no main menu bar, so `⌘N` and `⌘Q` may stop firing | P3-T1 | Quit stays in `•••`; move `⌘N` onto a visible in-widget control's `.keyboardShortcut` |
| An accessory app's windows may not become key on first click | P3-T1 | Call `NSApp.activate` when the panel or floating window is clicked |
| Collapsing the window may move it, because the window follows its content size | P3-T2 | Save the window's top-left point before collapsing and restore it after resizing |
| On-device speech recognition may be unavailable for the system language | P3-T3 | Disable the microphone with an explanation; never fall back to the server |

## Exit criteria

Automated (`TEST`): every unit test listed in the briefs passes. That includes the bubble's count text, the end-of-speech rule, and the trimmed-transcript check.

Manual (owner, once T3 is merged):

- [ ] There's no Dock icon and no ⌘-Tab entry. The menu-bar icon opens the widget as a panel, and clicking elsewhere closes it.
- [ ] A task added, completed or deleted in the panel shows up in the floating window straight away, and the other way round.
- [ ] The floating window can be closed and brought back from `•••` › Show floating window. Quit still works from `•••`.
- [ ] `⌘N` focuses the composer of the widget in front and never opens a second window.
- [ ] The pin button collapses the floating window to a circle showing the open-task count. The circle stays on top, follows you to other Spaces and can be dragged, and clicking it expands the widget in the same place.
- [ ] Clicking the microphone and saying a task adds it with the selected category after a short pause. Clicking again or pressing Escape cancels without adding anything.
- [ ] With microphone or speech permission denied, the microphone button is disabled and says why.
- [ ] With VoiceOver on, the pin button, the bubble and the microphone button are each announced with a meaningful name. With Reduce Motion on, nothing new slides or springs.
