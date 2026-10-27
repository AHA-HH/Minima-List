# P1-T1 — `TaskItem` and `Category`

**Phase:** [1 — Core loop](README.md)
**Design reference:** §10 (task model), §9 (category color tokens), §12 (don't rely on color alone)
**Depends on:** Phase 0

## Goal

The task value type and its category, with each category owning its display label, color and SF Symbol, so views never duplicate those rules.

## Files

- `MinimaList/Model/TaskItem.swift` (new)
- `MinimaListTests/TaskItemTests.swift` (new)

## Steps

1. In `TaskItem.swift`, use `import Foundation` and `import struct SwiftUI.Color` only (`CLAUDE.md` Layout rule for `Model/`).
2. Define `TaskItem` exactly as design §10: `struct TaskItem: Identifiable, Codable, Equatable` with `let id: UUID`, `var title: String`, `var category: Category`, `var isComplete: Bool`, `var createdAt: Date`. Add a memberwise-style `init` whose `id`, `isComplete` and `createdAt` default to `UUID()`, `false` and `.now`.
3. Define `enum Category: String, Codable, CaseIterable` with cases `focus`, `life`, `later`. The raw values are what gets saved, so they must stay `"focus"`, `"life"`, `"later"`.
4. Give `Category` three computed properties:

   | Property | `focus` | `life` | `later` |
   | --- | --- | --- | --- |
   | `label: String` | `Focus` | `Life` | `Later` |
   | `color: Color` | coral, `Color(red: 1.00, green: 0.48, blue: 0.40)` | soft blue, `Color(red: 0.45, green: 0.66, blue: 1.00)` | muted violet, `Color(red: 0.66, green: 0.55, blue: 0.90)` |
   | `symbol: String` (SF Symbol name) | `scope` | `leaf` | `tray` |

## Tests that define done

In `TaskItemTests.swift` (Swift Testing):

- A `TaskItem` encoded with `JSONEncoder` and decoded with `JSONDecoder` equals the original, for every category and both completion states.
- The new-task defaults hold: `isComplete == false`, and two new items get different `id`s.
- `Category.allCases.map(\.rawValue) == ["focus", "life", "later"]`, so persisted data stays readable.
- Every category has a non-empty `label`, and `NSImage(systemSymbolName: category.symbol, accessibilityDescription: nil)` is non-nil, so each symbol name really exists. (The test file may `import AppKit`; only `Model/` is restricted.)
- Decoding JSON with an unknown category raw value (e.g. `"someday"`) throws rather than crashing.

## Must pass

```sh
# BUILD and TEST from CLAUDE.md, then:
grep -rnE '^[[:space:]]*(@[A-Za-z_]+[[:space:]]+)*import[[:space:]]+([a-z]+[[:space:]]+)?SwiftUI\b' MinimaList/Model/ | grep -vF 'import struct SwiftUI.Color'
test -f MinimaList/Model/TaskItem.swift && test -f MinimaListTests/TaskItemTests.swift || echo "FAIL: files missing"
```

The block prints nothing when the task passes.

## Do not

- Import SwiftUI (beyond `struct SwiftUI.Color`) or AppKit in `Model/`.
- Add fields beyond design §10 (no due dates, notes, order index or priority).
- Make `Category` user-configurable or add cases (design §16 Q4 is still open).
- Edit `MinimaList.xcodeproj` (synchronised folders pick the files up).
