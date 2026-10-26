# P0-T1 — Create the Xcode project

**Phase:** [0 — Project scaffold](README.md)
**Design reference:** §11 (macOS 14+, SwiftUI with AppKit interop), §15 Phase 0
**Depends on:** P0-T3

## Goal

A SwiftUI macOS app project named `MinimaList` that builds and tests from the command line on a clean clone.

## Files

- `MinimaList.xcodeproj/` (new, including `xcshareddata/xcschemes/MinimaList.xcscheme`)
- `MinimaList/` (new; template sources, assets and entitlements)
- `MinimaListTests/` (new; template unit test)

## Steps

1. **Human step (Xcode GUI):** there is no supported command line for this. In Xcode, choose File › New › Project › macOS › App, then enter:

   | Field | Value |
   | --- | --- |
   | Product Name | `MinimaList` |
   | Organization Identifier | `io.github.aha-hh` (or your own reverse-DNS) |
   | Interface | SwiftUI |
   | Language | Swift |
   | Testing System | Swift Testing with XCTest UI Tests |
   | Storage | None |

   Save it **at the repository root**, so that `MinimaList.xcodeproj` sits next to `README.md`. Untick "Create Git repository", because the repo already exists.
2. Delete the `MinimaListUITests` target and its folder. Phase 0 has no UI tests (see the README's out-of-scope list).
3. In the `MinimaList` target, set **macOS Deployment Target** to `14.0`. Set it on the `MinimaListTests` target too.
4. Product › Scheme › Manage Schemes: tick **Shared** for `MinimaList`. Without this, the scheme lives only in the ignored `xcuserdata/`, and `BUILD`/`TEST` fail on a fresh clone.
5. Leave the template `ContentView` and the example test as they are.

## Tests that define done

- The template test in `MinimaListTests` runs and passes under `TEST`. This proves that the test target builds and that `@testable import MinimaList` links.
- `MACOSX_DEPLOYMENT_TARGET` is `14.0` for both targets.
- The shared scheme file is tracked: `git ls-files --others --exclude-standard` (before committing) lists `MinimaList.xcodeproj/xcshareddata/xcschemes/MinimaList.xcscheme`.
- Running the built app opens a single window showing the template content (manual check; record it in the review).

## Must pass

```sh
# BUILD and TEST from README.md, then:
xcodebuild -project MinimaList.xcodeproj -showBuildSettings -target MinimaList      | grep -E ' MACOSX_DEPLOYMENT_TARGET = 14\.0$'
xcodebuild -project MinimaList.xcodeproj -showBuildSettings -target MinimaListTests | grep -E ' MACOSX_DEPLOYMENT_TARGET = 14\.0$'
git status --porcelain | grep -c xcuserdata   # must print 0
```

## Do not

- Add Swift packages or any other dependency.
- Change the template `ContentView`/`App` code beyond what Xcode generates. Real UI starts in Phase 1.
- Commit `xcuserdata/` or build output.
- Use APIs newer than macOS 14 (the Phase 1 code depends on this target).
