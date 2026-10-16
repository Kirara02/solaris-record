import 'dart:io';

import 'package:flutter/foundation.dart';

/// `os_arch` of the running app (`android_arm64`, `windows_x64`, ...), read
/// from the Dart VM version string, which ends in `on "os_arch"`.
String updatePlatform() {
  final match = RegExp(r'on "([a-z0-9]+_[a-z0-9]+)"')
      .firstMatch(Platform.version);
  return match?.group(1) ?? '';
}

/// Whether this build can look for updates: every platform that has a release
/// download. iOS and web have none.
bool get updatesSupported =>
    !kIsWeb &&
    (Platform.isAndroid ||
        Platform.isWindows ||
        Platform.isMacOS ||
        Platform.isLinux);

/// Whether the update can be downloaded and installed from inside the app.
/// Other platforms open the download in the browser.
bool get canInstallInApp => !kIsWeb && Platform.isAndroid;
