# P0-T4 — Local-only sandbox

**Phase:** [0 — Project scaffold](README.md)
**Design reference:** §3 goal 4 (local-first), §11 ("no network permission is needed")
**Depends on:** P0-T1

## Goal

Make the built app sandboxed with no network access, so the local-only promise is enforced by the OS and not just by convention.

## Files

- `MinimaList/MinimaList.entitlements` (new)
- `MinimaList.xcodeproj/project.pbxproj` (one build setting on the `MinimaList` target)

## Steps

No Xcode GUI is needed; both steps are text edits.

1. Create `MinimaList/MinimaList.entitlements`: an XML property list whose only key is `com.apple.security.app-sandbox` set to `true`. Leaving out network and file-access keys is what keeps the app local-only. The app never opens files (persistence uses `UserDefaults`, design §10), so least privilege says grant no file access.
2. In the `MinimaList` target's `Debug` and `Release` configurations, set `CODE_SIGN_ENTITLEMENTS = MinimaList/MinimaList.entitlements`. Don't add `ENABLE_APP_SANDBOX` or other capability build settings; the entitlements file is the single source of truth.
3. Check that the entitlements file is used for signing only and isn't copied into the app bundle. The `MinimaList/` folder is a synchronised group, so check the built app has no `Contents/Resources/MinimaList.entitlements`.

## Tests that define done

The entitlements signed into the built app (not just the `.entitlements` source file, since Xcode may also inject entitlements from build settings) must satisfy all of these:

- `com.apple.security.app-sandbox` is `true`.
- No key starts with `com.apple.security.network.`.
- No key starts with `com.apple.security.files.`.
- No key starts with `com.apple.security.temporary-exception`.
- From P3-T3: `com.apple.security.device.audio-input` is `true` (voice capture, design §8.8), and no key other than `app-sandbox`, `device.audio-input` and `get-task-allow` (added by Debug signing) is signed in.

## Must pass

```sh
# Run BUILD from README.md immediately before this block, not TEST: TEST re-signs the
# app with temporary test-host exceptions (e.g. read access to /), which would be checked instead.
# BUILD, then:
APP=$(xcodebuild -project MinimaList.xcodeproj -scheme MinimaList -showBuildSettings 2>/dev/null \
  | awk -F' = ' '/ BUILT_PRODUCTS_DIR = /{d=$2} / FULL_PRODUCT_NAME = /{n=$2} END{print d"/"n}')
ENT=$(codesign -d --entitlements - --xml "$APP" 2>/dev/null | plutil -convert xml1 -o - -)
echo "$ENT" | grep -A1 'com.apple.security.app-sandbox' | grep -q '<true/>' || echo "FAIL: not sandboxed"
echo "$ENT" | grep -A1 'com.apple.security.device.audio-input' | grep -q '<true/>' || echo "FAIL: no microphone entitlement (P3-T3)"
# Only these keys may be signed in; get-task-allow is added by Debug signing.
echo "$ENT" | grep -o '<key>[^<]*</key>' | sed -E 's#</?key>##g' \
  | grep -vxE 'com\.apple\.security\.(app-sandbox|device\.audio-input|get-task-allow)' | sed 's/^/FAIL: extra entitlement: /'
test -e "$APP/Contents/Resources/MinimaList.entitlements" && echo "FAIL: entitlements copied into bundle"
true  # a pass prints nothing; judge by output, not exit code
```

The command prints nothing when the task passes. `TEST` must still pass too, because the sandboxed app hosts the unit tests.

## Do not

- Disable the sandbox to get around a build or test problem; report the problem instead.
- Add any entitlement or capability (iCloud, keychain sharing, network, file access).
