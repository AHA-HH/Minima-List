# P0-T1 — Create the Xcode project

**Phase:** [0 — Project scaffold](README.md)
**Design reference:** §11 (macOS 14+, SwiftUI with AppKit interop), §15 Phase 0
**Depends on:** P0-T3

## Goal

A SwiftUI macOS app project named `MinimaList` that builds and tests from the command line on a clean clone. The project is **written as text**, not created with Xcode's New Project wizard, so no step needs the Xcode GUI. Xcode must still be able to open it normally.

## Files

- `MinimaList.xcodeproj/project.pbxproj` (new, hand-written)
- `MinimaList.xcodeproj/xcshareddata/xcschemes/MinimaList.xcscheme` (new, shared scheme)
- `MinimaList/MinimaListApp.swift` (new)
- `MinimaList/ContentView.swift` (new; P0-T2 moves it to `Views/`)
- `MinimaListTests/MinimaListTests.swift` (new)

Nothing else. In particular: no `Info.plist` file, no asset catalog and no entitlements file. T4 adds the entitlements.

## Steps

1. **Write `project.pbxproj` in the modern format** (`objectVersion = 77`, which Xcode 16+ uses), so that the folders `MinimaList/` and `MinimaListTests/` are each a `PBXFileSystemSynchronizedRootGroup`. Any file in those folders is part of its target automatically, so later tasks never edit the project file to add a source file. Object IDs must be unique 24-character uppercase hex values.
2. **Targets:**

   | Target | Product type | Key build settings |
   | --- | --- | --- |
   | `MinimaList` | `com.apple.product-type.application` | `PRODUCT_BUNDLE_IDENTIFIER = io.github.aha-hh.MinimaList`, `GENERATE_INFOPLIST_FILE = YES`, `MACOSX_DEPLOYMENT_TARGET = 14.0`, `SWIFT_VERSION = 5.0`, `CODE_SIGN_STYLE = Manual`, `CODE_SIGN_IDENTITY = "-"` (sign to run locally; T4's entitlement check needs a signed app), no `DEVELOPMENT_TEAM` |
   | `MinimaListTests` | `com.apple.product-type.bundle.unit-test` | `TEST_HOST = $(BUILT_PRODUCTS_DIR)/MinimaList.app/Contents/MacOS/MinimaList`, `BUNDLE_LOADER = $(TEST_HOST)`, `PRODUCT_BUNDLE_IDENTIFIER = io.github.aha-hh.MinimaListTests`, `GENERATE_INFOPLIST_FILE = YES`, `MACOSX_DEPLOYMENT_TARGET = 14.0`, same signing settings, and a target dependency on `MinimaList` |

   Both targets need `Debug` and `Release` configurations.
3. **Shared scheme** `MinimaList`: builds the app, uses `MinimaListTests` as its test target, and launches the app on Run. It must be in `xcshareddata/`, because `xcuserdata/` is gitignored and `BUILD`/`TEST` would fail on a fresh clone.
4. **Sources, matching what Xcode's App template would generate:**
   - `MinimaListApp.swift`: `@main struct MinimaListApp: App` with `WindowGroup { ContentView() }`.
   - `ContentView.swift`: a `View` showing a globe image and the text `Hello, world!` with padding.
   - `MinimaListTests.swift`: `import Testing` and `@testable import MinimaList`, with one `@Test` that constructs `ContentView()`. This proves the test target links against the app module.
5. Build and test with the commands below until both pass. If `xcodebuild` rejects the project, fix the project file. Don't fall back to the wizard or to a generator tool.

## Tests that define done

- `TEST` runs the one Swift Testing test and it passes.
- `MACOSX_DEPLOYMENT_TARGET` is `14.0` for both targets.
- Both source folders are synchronised groups, and no `.swift` file is listed individually in `project.pbxproj`.
- The scheme is shared and tracked by git, and `xcodebuild -list` shows it.
- A fresh `git clone` of the branch passes `BUILD` with no other setup, which proves nothing depends on untracked or per-user files.
- Running the built app opens a single window showing "Hello, world!". This is a manual check; record it in the review.

## Must pass

```sh
# BUILD and TEST from README.md, then:
plutil -lint MinimaList.xcodeproj/project.pbxproj
xcodebuild -list -project MinimaList.xcodeproj | grep -qE '^\s+MinimaList$' || echo "FAIL: shared scheme not listed"
git ls-files --error-unmatch MinimaList.xcodeproj/xcshareddata/xcschemes/MinimaList.xcscheme >/dev/null
xcodebuild -project MinimaList.xcodeproj -showBuildSettings -target MinimaList      | grep -qE ' MACOSX_DEPLOYMENT_TARGET = 14\.0$' || echo "FAIL: app target"
xcodebuild -project MinimaList.xcodeproj -showBuildSettings -target MinimaListTests | grep -qE ' MACOSX_DEPLOYMENT_TARGET = 14\.0$' || echo "FAIL: test target"
test "$(grep -c 'isa = PBXFileSystemSynchronizedRootGroup' MinimaList.xcodeproj/project.pbxproj)" -eq 2 || echo "FAIL: synced groups"
grep -E 'PBXFileReference.*\.swift' MinimaList.xcodeproj/project.pbxproj && echo "FAIL: swift file listed by hand"
D=$(mktemp -d) && git clone -q . "$D/c" && (cd "$D/c" && xcodebuild -project MinimaList.xcodeproj -scheme MinimaList -destination 'platform=macOS' build -quiet) && echo "clean clone: BUILD ok"
git status --porcelain | grep -c xcuserdata   # must print 0
```

Apart from the `plutil` "OK" line, the clean-clone "BUILD ok" line and the final `0`, the block prints nothing.

## Do not

- Use Xcode's New Project wizard, XcodeGen, Tuist or any other project generator.
- Add Swift packages or any other dependency.
- Add an `Info.plist`, asset catalog, entitlements file, UI test target, or any app code beyond the template equivalents above. Real UI starts in Phase 1.
- Commit `xcuserdata/` or build output.
- Use APIs newer than macOS 14.
