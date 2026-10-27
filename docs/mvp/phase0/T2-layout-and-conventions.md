# P0-T2 — Source layout and `CLAUDE.md`

**Phase:** [0 — Project scaffold](README.md)
**Design reference:** §10 (state ownership), §11, §15
**Depends on:** P0-T1

## Goal

Fix the source layout that Phase 1 files go into, and write the conventions file the `reviewer` agent checks every later task against.

## Files

- `MinimaList/Views/ContentView.swift` (moved from `MinimaList/ContentView.swift`)
- `CLAUDE.md` (new, at the repository root)

## Steps

1. Move `MinimaList/ContentView.swift` to `MinimaList/Views/ContentView.swift`. Xcode 16+ projects use folder-synchronised groups, so moving the file on disk is enough. If the build can't find the file, add it to the target in Xcode instead.
2. Do **not** create empty `Model/` or `Platform/` folders. Git doesn't track empty folders; Phase 1 creates them with their first file.
3. Create `CLAUDE.md` with these sections:
   - **Project:** one line describing a minimal, local-only floating task widget for macOS, built with SwiftUI and AppKit interop, plus a link to `docs/design/Minima-List.md`, and a link to `docs/mvp/` as the place for phase plans and task briefs.
   - **Layout:**
     - `MinimaList/Model/`: data and persistence. No `import SwiftUI`; the one exception is `import struct SwiftUI.Color`, so `TaskCategory` can own its color (design §10).
     - `MinimaList/Views/`: SwiftUI views.
     - `MinimaList/Platform/`: AppKit interop.
     - `MinimaListTests/`: unit tests.
     - `MinimaList/` (root): only `MinimaListApp.swift` (the `@main` entry point) and `MinimaList.entitlements`.
   - **Checks:** the exact `BUILD` and `TEST` commands from the phase README, labelled as the repository's full checks.
   - **Rules:**
     - Target macOS 14. No APIs above it without `if #available`.
     - The app is local-only: no networking code and no network entitlements.
     - No third-party dependencies without the owner's sign-off.
     - Write unit tests with Swift Testing (`import Testing`).
     - `TaskStore` is the only owner of task data (design §10).
     - Changing a rule in this file needs the owner's sign-off.

## Tests that define done

- `BUILD` and `TEST` pass after the move.
- `MinimaList/ContentView.swift` no longer exists, and `MinimaList/Views/ContentView.swift` does.
- `CLAUDE.md` contains the `BUILD` and `TEST` commands exactly as written in the phase README.

## Must pass

```sh
# BUILD and TEST from README.md, then:
test ! -e MinimaList/ContentView.swift && test -f MinimaList/Views/ContentView.swift
grep -qF 'xcodebuild -project MinimaList.xcodeproj -scheme MinimaList -destination "platform=macOS,arch=$(uname -m)" build' CLAUDE.md
grep -qF 'xcodebuild -project MinimaList.xcodeproj -scheme MinimaList -destination "platform=macOS,arch=$(uname -m)" test'  CLAUDE.md
```

## Do not

- Edit the contents of `ContentView.swift`; only move it.
- Add placeholder files (`.gitkeep`, empty Swift files) to create folders.
- Put design content in `CLAUDE.md`; link to the design document instead.
