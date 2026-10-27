# P0-T5 — Zed editor setup

**Phase:** [0 — Project scaffold](README.md)
**Design reference:** §15 Phase 0
**Depends on:** P0-T1 (needs `MinimaList.xcodeproj` and its shared scheme) and P0-T3 (ignores `buildServer.json`)

## Goal

Edit the project day to day in Zed, with working autocomplete, go-to-definition and inline compiler errors. After P0-T1, Xcode is needed only for its command-line tools.

## Background

Zed's Swift support comes from `sourcekit-lsp`. On its own it understands Swift Packages, not `.xcodeproj` files. `xcode-build-server` connects the two: it reads the compiler flags from Xcode's build logs and serves them to `sourcekit-lsp`.

## Files

- `buildServer.json` (generated at the repository root, **gitignored**, specific to each machine)
- `CLAUDE.md` (add one setup line under a new **Editor** heading)

## Steps

1. Install the bridge: `brew install xcode-build-server`.
2. In Zed, install the **Swift** extension (Extensions panel, search "Swift").
3. From the repository root, generate the config:

   ```sh
   xcode-build-server config -project MinimaList.xcodeproj -scheme MinimaList
   ```

4. Run `BUILD` from the phase README once. `xcode-build-server` reads the flags from that build's log.
5. Open the repository in Zed (`zed .`). Open `MinimaList/Views/ContentView.swift` and restart the language server if Zed was already open.
6. Add to `CLAUDE.md`:

   ```md
   ## Editor
   Zed + `sourcekit-lsp` via `xcode-build-server`. Per machine: `brew install xcode-build-server`,
   then `xcode-build-server config -project MinimaList.xcodeproj -scheme MinimaList` and run BUILD once.
   ```

## Tests that define done

- `buildServer.json` exists at the repository root and is ignored by git.
- In Zed, in `ContentView.swift`:
  - Hovering `VStack` shows its SwiftUI documentation.
  - Typing `Text(1)` shows an inline compiler error within a few seconds. Undo the change afterwards.
  - Go-to-definition on `ContentView` (from the `App` file) jumps to the struct.

  These are manual checks; record what you saw in the review.

## Must pass

```sh
test -f buildServer.json && git check-ignore -q buildServer.json || echo "FAIL: buildServer.json missing or tracked"
grep -qF "xcode-build-server config -project MinimaList.xcodeproj -scheme MinimaList" CLAUDE.md || echo "FAIL: CLAUDE.md editor note missing"
```

`BUILD` and `TEST` must still pass.

## Do not

- Commit `buildServer.json`.
- Add project-level Zed settings (`.zed/`) unless a check above fails without them; if one does, record which and why.
- Change the Xcode project or scheme to suit the editor.
