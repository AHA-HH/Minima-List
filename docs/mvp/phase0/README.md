# Phase 0 — Project scaffold

**Objective:** Minima-List MVP ([design document](../../design/Minima-List.md), §15)
**Goal:** an empty macOS app that builds, runs and has a test target, plus the repo conventions that later phases are reviewed against.
**Starting point:** the repository contains only `LICENSE`, `README.md` and `docs/`. No source code exists yet.

## Tasks

Run them in this order. T3 comes first so that Xcode's per-user files never get committed.

| Order | ID | Brief | Depends on |
| --- | --- | --- | --- |
| 1 | P0-T3 | [Xcode `.gitignore`](T3-gitignore.md) | — |
| 2 | P0-T1 | [Create the Xcode project](T1-xcode-project.md) | P0-T3 |
| 3 | P0-T2 | [Source layout and `CLAUDE.md`](T2-layout-and-conventions.md) | P0-T1 |
| 4 | P0-T4 | [Local-only sandbox](T4-sandbox.md) | P0-T1 |
| 5 | P0-T5 | [Zed editor setup](T5-zed-editor.md) | P0-T1, P0-T3 |

- [ ] P0-T3 · [ ] P0-T1 · [ ] P0-T2 · [ ] P0-T4 · [ ] P0-T5

**Editing workflow:** no step needs the Xcode GUI. P0-T1 writes the project file as text. All editing happens in Zed (set up in P0-T5), and builds and tests run through `xcodebuild`.

Tick an item only after the `reviewer` agent returns `PASS` for that task.

## Shared commands

Run every command from the repository root. Briefs refer to these by name.

```sh
# BUILD
xcodebuild -project MinimaList.xcodeproj -scheme MinimaList -destination 'platform=macOS' build

# TEST
xcodebuild -project MinimaList.xcodeproj -scheme MinimaList -destination 'platform=macOS' test
```

## Out of scope for this phase

The reviewer flags any of these as a scope violation:

- Any app code beyond the Xcode template: no `TaskItem`, `TaskStore`, window configuration or styling. That work starts in Phase 1.
- Third-party project dependencies (Swift packages, CocoaPods, XcodeGen, Tuist). `xcode-build-server` (P0-T5) is allowed because it's a tool installed on each developer's machine; the project never links or needs it.
- CI configuration.
- Edits to the design document other than ticking §15 checkboxes.
- A UI test target.

## Exit criteria

- [ ] `BUILD` and `TEST` both succeed on a clean clone, with no Xcode GUI step needed after cloning.
- [ ] Launching the app opens a single window showing the template content.
- [ ] `CLAUDE.md` exists and lists `BUILD` and `TEST` as the repository's full checks.
- [ ] The built app is sandboxed and has no network entitlements.
- [ ] Zed shows autocomplete and inline compiler errors for project sources.
