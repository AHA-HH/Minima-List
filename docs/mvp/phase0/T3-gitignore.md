# P0-T3 — Xcode `.gitignore`

**Phase:** [0 — Project scaffold](README.md)
**Design reference:** §15 Phase 0
**Depends on:** nothing. Do this before P0-T1.

## Goal

Keep per-user Xcode state, build output and Finder metadata out of git, while still tracking the project file and shared schemes.

## Files

- `.gitignore` (new, at the repository root)

## Steps

1. Create `.gitignore` with:

   ```gitignore
   .DS_Store
   xcuserdata/
   DerivedData/
   build/
   *.xcuserstate
   # xcode-build-server config (P0-T5) holds absolute paths for one machine
   buildServer.json
   ```

## Tests that define done

- These paths are ignored: `MinimaList.xcodeproj/xcuserdata/me.xcuserdatad`, `DerivedData/x`, `build/x`, `.DS_Store`, `buildServer.json`.
- These paths are **not** ignored: `MinimaList.xcodeproj/project.pbxproj`, `MinimaList.xcodeproj/xcshareddata/xcschemes/MinimaList.xcscheme`.

## Must pass

```sh
for p in MinimaList.xcodeproj/xcuserdata/me.xcuserdatad DerivedData/x build/x .DS_Store buildServer.json; do
  git check-ignore -q "$p" || echo "NOT IGNORED: $p"; done
for p in MinimaList.xcodeproj/project.pbxproj MinimaList.xcodeproj/xcshareddata/xcschemes/MinimaList.xcscheme; do
  git check-ignore -q "$p" && echo "WRONGLY IGNORED: $p"; done
```

The command prints nothing when the task passes. `git check-ignore` matches against patterns, so the paths don't need to exist.

## Do not

- Ignore `*.xcodeproj`, `project.pbxproj`, `xcshareddata/` or `*.entitlements`.
- Add ignore rules for tools the project doesn't use (CocoaPods, Carthage, fastlane, SwiftPM `.build/`).
