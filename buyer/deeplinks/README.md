# Deep linking — App Links (Android) & Universal Links (iOS)

Makes `https://links.paysft.com/projects/{id}` open the buyer app when
installed, and fall back to the website otherwise. The in-app routing +
native config are already wired; the two files here must be **hosted on the
website** to complete verification.

## App side (already done in this repo)
- `app_links` package + `lib/core/services/deep_link_service.dart` route
  `/projects/{id}` → `PropertyDetailsPage`. Initialized in `lib/main.dart`.
- Android: `<intent-filter android:autoVerify="true">` for
  `https://links.paysft.com/projects/*` in `AndroidManifest.xml`.
- iOS: `ios/Runner/Runner.entitlements` with
  `applinks:links.paysft.com`.
  **Still TODO in Xcode:** open Runner target → Signing & Capabilities →
  add **Associated Domains** (this points the build at `Runner.entitlements`).

## Website side (host these — the missing piece)

### Android — `/.well-known/assetlinks.json`
Serve `assetlinks.json` at
`https://links.paysft.com/.well-known/assetlinks.json`
(HTTPS, `Content-Type: application/json`, HTTP 200, no redirects).

Replace the `sha256_cert_fingerprints` placeholders with your app's signing
certificate SHA-256. Get it with:

```
# from paysft-mobile/buyer/android
./gradlew signingReport
# copy the SHA-256 (or): keytool -list -v -keystore <your.keystore> -alias <alias>
```

- `com.example.buyer` → your **release** signing SHA-256
- `com.example.buyer.dev` → the **debug/dev** signing SHA-256 (keep only if you
  want deep links to work on dev builds; drop this entry for production-only)

### iOS — `/.well-known/apple-app-site-association`
Serve `apple-app-site-association` at
`https://links.paysft.com/.well-known/apple-app-site-association`
(HTTPS, `Content-Type: application/json`, **no** `.json` extension, no redirects).

Replace `REPLACE_WITH_TEAMID` with your Apple Developer **Team ID**
(e.g. `ABCDE12345.com.example.buyer`).

## Verify
- Android: `adb shell pm verify-app-links --re-verify com.example.buyer` then
  `adb shell pm get-app-links com.example.buyer` (look for `verified`).
- iOS: install via TestFlight/device and tap a link; use Apple's AASA validator.
