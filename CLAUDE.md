# CLAUDE.md

## Project

Minima-List is a minimal, local-only macOS task widget built with SwiftUI. The design is in [docs/design/Minima-List.md](docs/design/Minima-List.md); phase plans and task briefs are in [docs/mvp/](docs/mvp/).

## Layout

- `MinimaList/Model/`: data and persistence. No SwiftUI imports.
- `MinimaList/Views/`: SwiftUI views.
- `MinimaList/Platform/`: AppKit interop.
- `MinimaListTests/`: unit tests.

## Checks

These are the repository's full checks. Run them from the repository root.

```sh
# BUILD
xcodebuild -project MinimaList.xcodeproj -scheme MinimaList -destination "platform=macOS,arch=$(uname -m)" build

# TEST
xcodebuild -project MinimaList.xcodeproj -scheme MinimaList -destination "platform=macOS,arch=$(uname -m)" test
```

Run the sandbox entitlement check in [docs/mvp/phase0/T4-sandbox.md](docs/mvp/phase0/T4-sandbox.md) (Must pass) right after BUILD, never after TEST, because TEST re-signs the app with test-host exceptions.

## Rules

- Target macOS 14. No APIs above it without `if #available`.
- The app is local-only: no networking code and no network entitlements.
- No third-party dependencies without the owner's sign-off.
- Write unit tests with Swift Testing (`import Testing`).
- `TaskStore` is the only owner of task data (design §10).
- Changing a rule in this file needs the owner's sign-off.
