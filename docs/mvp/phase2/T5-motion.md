# P2-T5 — Motion and Reduce Motion

**Phase:** [2 — Daily usability](README.md)
**Design reference:** §9 Motion (spring on toggle, fade on hover delete, ease-out removal, no looping or attention-seeking effects), §12 (respect Reduce Motion)
**Depends on:** P2-T3 (edits `TaskRow.swift`), P2-T4 (edits `ContentView.swift`)

## Goal

Completing, hovering and removing feel gentle, and with Reduce Motion on the movement goes away.

## Files

- `MinimaList/Views/Motion.swift` (new)
- `MinimaList/Views/TaskRow.swift` (edit)
- `MinimaList/Views/ContentView.swift` (edit)
- `MinimaListTests/MotionTests.swift` (new)

## Steps

1. In `Motion.swift`, one small `enum Motion` with the app's three animations, each taking `reduceMotion: Bool`, so the rules live in one tested place:
   - `static func toggle(reduceMotion: Bool) -> Animation?`: a short spring (about 0.3 s) normally, `nil` with Reduce Motion.
   - `static func hover(reduceMotion: Bool) -> Animation?`: a short ease-in-out fade (about 0.15 s) in both cases. Fades aren't motion, so Reduce Motion keeps them.
   - `static func removal(reduceMotion: Bool) -> Animation?`: a brief ease-out (about 0.2 s) normally, a plain short fade with Reduce Motion.
   - `static func rowTransition(reduceMotion: Bool) -> AnyTransition`: `.opacity` combined with a slide to the trailing edge normally, `.opacity` only with Reduce Motion.
2. Read `@Environment(\.accessibilityReduceMotion)` in each view that animates.
3. `TaskRow`: animate the circle, title dimming and strikethrough with `.animation(Motion.toggle(reduceMotion:), value: task.isComplete)`, and the delete button's opacity with `.animation(Motion.hover(reduceMotion:), value: isHovered)`.
4. `ContentView`: give each row `.transition(Motion.rowTransition(reduceMotion:))`, and wrap the store calls that insert or remove rows (`add`, `remove`, `clearCompleted`, and toggling `isHidingCompleted`) in `withAnimation(Motion.removal(reduceMotion:))`, so rows fade or slide in and out instead of jumping. The empty state swapping in and out should fade, not jump.
5. Keep the timeline, progress bar and composer unanimated except as a side effect of the above.

## Tests that define done

In `MotionTests.swift` (Swift Testing):

- `Motion.toggle(reduceMotion: true)` is `nil`, and `Motion.toggle(reduceMotion: false)` isn't.
- `Motion.hover` isn't `nil` for either value.
- `Motion.removal(reduceMotion: false)` and `Motion.removal(reduceMotion: true)` are both non-`nil` and differ from each other.
- The existing `TaskRow` and `ContentView` tests still pass.

Window image (README convention): one PNG after a toggle has settled, to show nothing is left mid-animation or misplaced.

Manual checks (owner):

- Completing a task springs the circle into its checked state; reopening springs it back.
- The delete button fades in and out on hover.
- Deleting a task, clearing completed and hiding completed slide or fade the rows out, and the rows below move up smoothly.
- With System Settings › Accessibility › Display › Reduce motion on, the spring and slide are gone; rows only fade.
- Nothing loops or bounces on its own.

## Must pass

```sh
# BUILD and TEST from CLAUDE.md, then:
grep -rqF 'accessibilityReduceMotion' MinimaList/Views/ || echo "FAIL: Reduce Motion not read"
grep -rn 'repeatForever\|confetti' MinimaList/ && echo "FAIL: no looping or attention-seeking motion"
grep -rn '\.spring\|\.easeOut\|\.easeInOut' MinimaList/Views/ | grep -v 'Motion.swift' && echo "FAIL: animations belong in Motion.swift"
```

The block prints nothing when the task passes.

## Do not

- Add animations the design doesn't list (launch animation, progress-bar celebration, header motion).
- Animate the window itself.
- Change layout, colors or copy.
