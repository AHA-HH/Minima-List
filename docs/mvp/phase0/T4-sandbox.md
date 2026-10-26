# P0-T4 — Local-only sandbox

**Phase:** [0 — Project scaffold](README.md)
**Design reference:** §3 goal 4 (local-first), §11 ("no network permission is needed")
**Depends on:** P0-T1

## Goal

Make the built app sandboxed with no network access, so the local-only promise is enforced by the OS and not just by convention.

## Files

- `MinimaList/MinimaList.entitlements` and/or the `MinimaList` target's signing build settings, whichever the Xcode template used.

## Steps

1. Under the `MinimaList` target's Signing & Capabilities, make sure **App Sandbox** is on.
2. Under App Sandbox › Network, make sure both **Incoming** and **Outgoing Connections** are off.
3. Remove the template's **User Selected File** access, if present. The app never opens files (persistence uses `UserDefaults`, design §10), so least privilege says drop it.

## Tests that define done

The entitlements signed into the built app (not just the `.entitlements` source file, since Xcode may also inject entitlements from build settings) must satisfy all of these:

- `com.apple.security.app-sandbox` is `true`.
- No key starts with `com.apple.security.network.`.
- No key starts with `com.apple.security.files.`.

## Must pass

```sh
# BUILD from README.md, then:
APP=$(xcodebuild -project MinimaList.xcodeproj -scheme MinimaList -showBuildSettings 2>/dev/null \
  | awk -F' = ' '/ BUILT_PRODUCTS_DIR = /{d=$2} / FULL_PRODUCT_NAME = /{n=$2} END{print d"/"n}')
ENT=$(codesign -d --entitlements - --xml "$APP" 2>/dev/null | plutil -convert xml1 -o - -)
echo "$ENT" | grep -A1 'com.apple.security.app-sandbox' | grep -q '<true/>' || echo "FAIL: not sandboxed"
echo "$ENT" | grep -E 'com\.apple\.security\.(network|files)\.' && echo "FAIL: extra entitlements"
```

The command prints nothing when the task passes. `TEST` must still pass too, because the sandboxed app hosts the unit tests.

## Do not

- Disable the sandbox to get around a build or test problem; report the problem instead.
- Add any entitlement or capability (iCloud, keychain sharing, network, file access).
