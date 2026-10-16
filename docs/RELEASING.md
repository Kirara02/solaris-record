# Releasing

Releases are built by GitHub Actions (`.github/workflows/release.yml`) when you push a version tag. Android, Windows, Linux and macOS are built; iOS and web are not.

## One-time setup: Android signing key

Android updates only install over the same signing key, so create one key, keep it forever and back it up somewhere safe (losing it means users can't update, and it must never be committed).

```bash
keytool -genkeypair -v -keystore solaris-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias solaris
```

Create an environment named **`release`** (GitHub → Settings → Environments → New environment) and add these four secrets to it under *Environment secrets*. The Android job runs in that environment, so the secrets are only available to release builds. (Plain repository secrets with the same names also work.) Optionally add *Required reviewers* to the environment to approve each release before it is signed.

| Secret | Value |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | the keystore, base64 encoded: `base64 -i solaris-release.jks \| pbcopy` (macOS) or `base64 -w0 solaris-release.jks` (Linux) |
| `ANDROID_KEYSTORE_PASSWORD` | the keystore password |
| `ANDROID_KEY_ALIAS` | `solaris` (the alias you used) |
| `ANDROID_KEY_PASSWORD` | the key password |

The release workflow refuses to run without them, so a debug-signed APK is never published.

### Signing locally (optional)

Create `android/key.properties` (it is git-ignored):

```properties
storeFile=/absolute/path/to/solaris-release.jks
storePassword=...
keyAlias=solaris
keyPassword=...
```

Without that file, release builds fall back to the debug key, so `flutter run --release` still works for contributors.

## Making a release

1. Set the new version in `pubspec.yaml`, for example `version: 1.0.1+2`. Only the `1.0.1` part is used; CI sets the build number.
2. Commit and push to `main`, and wait for the CI check to pass.
3. Tag and push:

   ```bash
   git tag v1.0.1
   git push origin v1.0.1
   ```

   The workflow fails early if the tag does not match the version in `pubspec.yaml`. A tag with a suffix (`v1.1.0-beta.1`) is published as a pre-release.
4. When the run finishes, the release page has the Android APKs (per ABI), a Windows zip, a Linux tarball, a macOS zip and `SHA256SUMS.txt`.

## Known limits

- **Windows and macOS builds are not code-signed.** Windows shows a SmartScreen warning and macOS asks the user to right-click → Open. Signing needs a paid certificate (a Windows code-signing certificate, or an Apple Developer ID with notarization).
- **iOS** is not built here: it needs an Apple Developer account and signing certificates.
- **Web** is not built: the database needs extra wasm files and the game's API is probably blocked by CORS in browsers.
