---

Unofficial fan project, not affiliated with Kuro Games. Released under the MIT license.

### Downloads
| Platform | File | Notes |
|---|---|---|
| Android | `…-android-arm64-v8a.apk` | Most phones. Use `armeabi-v7a` for older 32-bit phones and `x86_64` for emulators. |
| Windows | `…-windows-x64.zip` | Extract, then run `solaris_record_app.exe`. |
| macOS | `…-macos.zip` | Contains `Solaris Record.app`. |
| Linux | `…-linux-x64.tar.gz` | Extract and run `solaris_record_app` (needs GTK 3). |

Verify a download with `SHA256SUMS.txt`.

### First run on Windows and macOS
These builds are not code-signed, so the system warns before opening them.
- **Windows**: SmartScreen shows *More info → Run anyway*.
- **macOS**: right-click the app and choose *Open*, or run `xattr -dr com.apple.quarantine "Solaris Record.app"`.
