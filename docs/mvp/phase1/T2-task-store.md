# P1-T2 — `TaskStore` and persistence

**Phase:** [1 — Core loop](README.md)
**Design reference:** §8.2 (add validation), §10 (persistence, state ownership), §13 (edge states)
**Depends on:** P1-T1

## Goal

The single owner of task data: it holds the list, derives progress, applies every mutation, and saves after each one, so a relaunch shows the same tasks.

## Files

- `MinimaList/Model/TaskStore.swift` (new)
- `MinimaListTests/TaskStoreTests.swift` (new)

## Steps

1. `import Foundation` and `import Observation` only. Declare `@MainActor @Observable final class TaskStore`.
2. State: `private(set) var tasks: [TaskItem]`, newest first. Derived, not stored: `completedCount: Int` and `progress: Double` (`completedCount / tasks.count`, and `0` when there are no tasks).
3. `init(defaults: UserDefaults = .standard, key: String = "tasks")`. Load by decoding `[TaskItem]` JSON from `defaults.data(forKey: key)`:
   - No data → empty list.
   - Data that fails to decode → empty list, **and first copy the raw bytes to `"\(key).corrupt"`** so the next save can't destroy the only copy. Don't crash, and don't show an alert.
4. Mutations, each saving immediately afterwards (JSON-encode `tasks` to `key`):
   - `add(title: String, category: TaskCategory)`: trim whitespace and newlines. If the result is empty, do nothing (no save). Otherwise insert a new `TaskItem` at index 0.
   - `toggle(_ id: TaskItem.ID)`: flip `isComplete` on that task. An unknown id does nothing.
   - `remove(_ id: TaskItem.ID)`: remove that task only. An unknown id does nothing.
   - `clearCompleted()`: remove every completed task.
5. Keep saving in one private method that every mutation calls, so there's one place that writes.

## Tests that define done

In `TaskStoreTests.swift` (Swift Testing, `@MainActor`). Each test uses its own `UserDefaults(suiteName: "test-\(UUID())")!` and removes that persistent domain at the end (see phase README).

- `add` trims leading and trailing whitespace and newlines; `add("   ")` and `add("")` leave `tasks` empty.
- `add` inserts at index 0: after adding "a" then "b", titles are `["b", "a"]`.
- `toggle` flips `isComplete` and a second `toggle` flips it back; `toggle` with an unknown id changes nothing.
- `remove` deletes only the target task.
- `clearCompleted` removes exactly the completed tasks and keeps the order of the rest.
- `progress` is `0` with no tasks, `0.5` with one of two complete, and `1` when all are complete; `completedCount` matches.
- Persistence round trip: mutate one store, create a **new** `TaskStore` on the same suite and key, and its `tasks` equals the first store's (ids, titles, categories, completion, dates).
- Every mutation persists: after each of `add`, `toggle`, `remove` and `clearCompleted`, a fresh store on the same suite sees the change.
- Corrupt data: put `Data("not json".utf8)` at the key. A new store loads empty without crashing, and `"tasks.corrupt"` holds exactly those bytes.

## Must pass

```sh
# BUILD and TEST from CLAUDE.md, then:
grep -rnE '^[[:space:]]*(@[A-Za-z_]+[[:space:]]+)*import[[:space:]]+([a-z]+[[:space:]]+)?SwiftUI\b' MinimaList/Model/ | grep -vF 'import struct SwiftUI.Color'
grep -rnE 'UserDefaults\.standard|defaults: *\.standard|TaskStore\(\)' MinimaListTests/ && echo "FAIL: tests must use isolated defaults"
```

The block prints nothing when the task passes.

## Do not

- Expose `tasks` as publicly settable; all changes go through the four mutation methods (`CLAUDE.md`: `TaskStore` is the only owner of task data).
- Add Combine, SwiftData, files on disk, or any store other than `UserDefaults`. Versioning and migration are Phase 3.
- Add undo, sorting options or filtering (hide completed is a view concern in Phase 2).
- Touch any view or the app file. Wiring the store into the UI is P1-T4.
