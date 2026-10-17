---

Unofficial fan project, not affiliated with Kuro Games. Released under the MIT license.

### Downloads
| Platform | File | Notes |
|---|---|---|
| Android | `…-android-arm64-v8a.apk` | Most phones. Use `armeabi-v7a` for older 32-bit phones and `x86_64` for emulators. |
| Windows | `…-windows-x64.zip` | Extract, then run `solaris_record_app.exe`. |
| macOS | `…-macos.dmg` | Open it and drag `Solaris Record.app` onto Applications, then eject the disk image. `…-macos.zip` holds the same app. |
| Linux | `…-linux-x64.tar.gz` | Extract and run `solaris_record_app` (needs GTK 3). |

Verify a download with `SHA256SUMS.txt`.

### First run on Windows and macOS
These builds are not code-signed, so the system warns before opening them.
- **Windows**: SmartScreen shows *More info → Run anyway*.
- **macOS**: drag the app to Applications first, then run `xattr -dr com.apple.quarantine "/Applications/Solaris Record.app"` in Terminal. On macOS 15 and later, right-click → *Open* no longer bypasses the warning; the other way is *System Settings → Privacy & Security → Open Anyway* after the first blocked launch.
