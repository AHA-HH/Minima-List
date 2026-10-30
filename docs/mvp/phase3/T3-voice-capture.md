# P3-T3 — Voice capture

**Phase:** [3 — Menu bar and voice](README.md)
**Design reference:** §8.8 (add a task by voice), §8.2 (validation), §6 and §11 (local only, on-device recognition, entitlement and Info.plist strings), §9 (composer wireframe; no looping motion), §12 (accessibility)
**Depends on:** P3-T2 (both edit `ContentView.swift`; this task also changes the app target's build settings)

## Goal

A microphone button in the composer listens with on-device speech recognition. The words appear in the composer as you speak, and after about 1.5 s of silence the task is added with the selected category, exactly as if you had pressed Return. Nothing leaves the Mac.

## Files

- `MinimaList/MinimaList.entitlements` (edit)
- `MinimaList.xcodeproj/project.pbxproj` (two build settings on the `MinimaList` target, Debug and Release)
- `MinimaList/Platform/SpeechCapture.swift` (new)
- `MinimaList/Views/ContentView.swift` (edit)
- `MinimaListTests/SpeechCaptureTests.swift` (new)
- `docs/mvp/phase0/T4-sandbox.md` (edit the Must pass block)

## Steps

1. Add `com.apple.security.device.audio-input` set to `true` to `MinimaList.entitlements`. It's the only new entitlement.
2. In the `MinimaList` target's Debug and Release configurations, add:
   - `INFOPLIST_KEY_NSMicrophoneUsageDescription = "Minima List listens only while the microphone button is on, to type the task you say."`
   - `INFOPLIST_KEY_NSSpeechRecognitionUsageDescription = "Speech is turned into text on this Mac. Nothing is sent anywhere."`
3. Extend the Must pass block in `docs/mvp/phase0/T4-sandbox.md` so any signed entitlement other than `com.apple.security.app-sandbox`, `com.apple.security.device.audio-input` and `com.apple.security.get-task-allow` (which Debug signing adds) prints `FAIL`. Check `device.audio-input` is `true`. Run the new block once against a build from `main` before this task to show it catches the missing entitlement, and say so in the PR.
4. Create `SpeechCapture` in `Platform/SpeechCapture.swift`, a `@MainActor @Observable final class` that owns `AVAudioEngine`, `SFSpeechRecognizer(locale: .current)`, the `SFSpeechAudioBufferRecognitionRequest` and its task. Views see only:
   - `private(set) var isListening: Bool` and `private(set) var transcript: String`.
   - `private(set) var unavailableReason: String?`, set with `unavailableReason(...)` below when `SpeechCapture` is created and again after each permission request, because permission statuses aren't observable.
   - `func start(onFinish: @escaping (String) -> Void)`, which asks for microphone (`AVCaptureDevice.requestAccess(for: .audio)`) and speech (`SFSpeechRecognizer.requestAuthorization`) permission the first time, then starts listening. Set `request.requiresOnDeviceRecognition = true` and `request.shouldReportPartialResults = true`. Each partial result whose text changed updates `transcript` and the time speech was last heard.
   - `func cancel()`, which stops the engine, removes the input tap, cancels the task and clears `transcript` without calling `onFinish`.

   While listening, check about four times a second with `shouldFinish(lastSpeechAt:now:)`. When it returns true, stop exactly as `cancel()` does, then call `onFinish` with the transcript. A recognition error stops listening as `cancel()` does.
5. Put the testable rules in `SpeechCapture` as `static` functions:
   - `static let silenceThreshold: TimeInterval = 1.5`
   - `static func shouldFinish(lastSpeechAt: Date?, now: Date, threshold: TimeInterval = silenceThreshold) -> Bool` is false when `lastSpeechAt` is `nil` (nothing said yet), and true once `now` is at least `threshold` after it.
   - `static func unavailableReason(microphone: AVAuthorizationStatus, speech: SFSpeechRecognizerAuthorizationStatus, recognizerAvailable: Bool, supportsOnDevice: Bool) -> String?` returns `nil` when voice capture can be used, including when permission has not been asked yet (`.notDetermined`). Otherwise it returns one help sentence: microphone denied or restricted, speech recognition denied or restricted, or on-device recognition not available for this language. Check them in that order. Never fall back to server recognition.
6. In `ContentView`:
   - Add `@State private var speech = SpeechCapture()`. Each widget has its own; don't share one between the panel and the floating window.
   - Between the text field and `+`, add a 40 × 40 microphone button styled like `+` but with `surfaceRaised` behind it. It shows `mic` with `textSecondary` when idle, and a steady `mic.fill` in `accentCoral` while listening. No pulse, no animation.
   - Its accessibility label is `Dictate task` when idle and `Stop dictating` while listening. When `speech.unavailableReason` is non-nil the button is `.disabled`, and the reason is both its `.help` and its `.accessibilityHint`.
   - Clicking it while idle saves the composer text, then calls `speech.start { text = $0; addTask() }`. Clicking it while listening calls `speech.cancel()` and restores the saved text.
   - While listening, `.onChange(of: speech.transcript)` copies the transcript into `text`.
   - `.onExitCommand` cancels and restores while listening, so Escape cancels (§8.8 step 5).
   - `.onDisappear` cancels, so closing the panel, hiding the floating window or collapsing it never leaves the microphone on.
7. An empty or whitespace-only transcript adds nothing. `addTask()` already sends everything through `TaskStore.add`, which trims and ignores blanks, so don't add a second check.

## Tests that define done

In `SpeechCaptureTests.swift` (Swift Testing, `@MainActor`, calling only the `static` functions; never create a `SpeechCapture` in tests, so no test touches the microphone):

- `shouldFinish` is false with `lastSpeechAt: nil`, however much time has passed (a pause before any speech doesn't end listening; design §15 unit test).
- It's false at 1.4 s after the last speech and true at 1.5 s and 3 s.
- `unavailableReason` is `nil` when everything is authorized and on-device recognition is supported, and also when both permissions are `.notDetermined`.
- It returns a microphone sentence for a denied microphone, a speech sentence for denied speech recognition, and a language sentence when `supportsOnDevice` or `recognizerAvailable` is false. When the microphone and speech are both denied, the microphone sentence wins.

The trimmed-transcript rule is `TaskStoreTests.addTrimsAndIgnoresBlank`, from P1-T2. Name it in the PR as this phase's transcript test, because the voice path finishes through `addTask()` and `store.add`.

Window image (README convention): the composer with the microphone button between the field and `+`. Probe only the idle and unavailable paths. Never grant the probe microphone or speech access, and don't click its microphone; if a permission prompt appears, deny it.

Manual checks (owner):

- Clicking the microphone the first time asks for microphone and speech permission.
- Saying a task shows the words in the composer, and about 1.5 s after you stop the task is added with the selected category.
- Clicking the microphone again, or pressing Escape, stops listening and adds nothing; what you had typed before comes back.
- With microphone or speech permission denied in System Settings, the button is disabled and its tooltip says why.
- Closing the panel or collapsing the floating window while listening turns the microphone off (the orange menu-bar dot goes away).
- With VoiceOver, the button reads "Dictate task" or "Stop dictating".

## Must pass

```sh
# BUILD from CLAUDE.md, then the extended sandbox check from ../phase0/T4-sandbox.md, then:
F=MinimaList/Platform/SpeechCapture.swift
grep -q 'requiresOnDeviceRecognition = true' "$F" || echo "FAIL: recognition must be on-device"
grep -rn 'AVAudioEngine\|SFSpeech' MinimaList/ | grep -v "^$F:" && echo "FAIL: Speech and audio code belongs in $F"
grep -rnE 'URLSession|NWConnection|Network\.framework|import Network' MinimaList/ && echo "FAIL: no networking"
grep -rn 'repeatForever' MinimaList/ && echo "FAIL: the recording state must not loop"
APP=$(xcodebuild -project MinimaList.xcodeproj -scheme MinimaList -showBuildSettings 2>/dev/null \
  | awk -F' = ' '/ BUILT_PRODUCTS_DIR = /{d=$2} / FULL_PRODUCT_NAME = /{n=$2} END{print d"/"n}')
for k in NSMicrophoneUsageDescription NSSpeechRecognitionUsageDescription; do
  /usr/libexec/PlistBuddy -c "Print :$k" "$APP/Contents/Info.plist" >/dev/null 2>&1 || echo "FAIL: missing $k"
done
# then TEST from CLAUDE.md.
```

The block prints nothing when the task passes.

## Do not

- Fall back to server recognition, or add any networking code or entitlement other than `device.audio-input`.
- Add wake words or always-on listening, several tasks from one utterance, voice commands, or choosing the category by voice (README out of scope).
- Pulse, animate or loop the recording state.
- Add a second blank-title check outside `TaskStore.add`.
- Grant a probe microphone access, or record real audio in tests.
