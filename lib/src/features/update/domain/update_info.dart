/// One downloadable file of a release.
class UpdateAsset {
  const UpdateAsset({
    required this.name,
    required this.url,
    this.sha256,
    this.size = 0,
  });

  final String name;
  final String url;

  /// Lowercase hex SHA-256 published by GitHub for the file, when known.
  final String? sha256;
  final int size;
}

/// The newest published release.
class UpdateInfo {
  const UpdateInfo({
    required this.version,
    required this.notes,
    required this.pageUrl,
    this.publishedAt,
    this.asset,
  });

  /// Version without the leading `v` (tag `v1.0.1` gives `1.0.1`).
  final String version;

  /// Release description, still as markdown.
  final String notes;

  /// The release page, always available as a fallback.
  final String pageUrl;
  final DateTime? publishedAt;

  /// The file for this device, null when the release has none for it.
  final UpdateAsset? asset;
}

/// Whether [latest] is a newer version than [current].
///
/// Compares `major.minor.patch`. A pre-release suffix (`1.0.0-rc.1`) sorts
/// before the same version without one; two pre-releases of one version are
/// treated as equal.
bool isNewerVersion(String latest, String current) {
  ({List<int> numbers, bool preRelease})? parse(String v) {
    final text = v.trim().replaceFirst(RegExp(r'^[vV]'), '').split('+').first;
    final dash = text.indexOf('-');
    final core = dash < 0 ? text : text.substring(0, dash);
    final numbers = <int>[];
    for (final part in core.split('.')) {
      final n = int.tryParse(part);
      if (n == null) return null;
      numbers.add(n);
    }
    while (numbers.length < 3) {
      numbers.add(0);
    }
    return (numbers: numbers, preRelease: dash >= 0);
  }

  final a = parse(latest);
  final b = parse(current);
  if (a == null || b == null) return false;
  for (var i = 0; i < 3; i++) {
    if (a.numbers[i] != b.numbers[i]) return a.numbers[i] > b.numbers[i];
  }
  return b.preRelease && !a.preRelease;
}

/// The end of the release file name that fits [platform]. These names are a
/// contract with the release workflow (`.github/workflows/release.yml`): if
/// the workflow renames a file, update this too, or that platform is offered
/// no direct download.
///
/// The end of the release file name that fits [platform], an `os_arch` string
/// such as `android_arm64` or `windows_x64` (see `updatePlatform`). Null for
/// platforms with no build, like iOS.
String? assetSuffixFor(String platform) => switch (platform) {
  'android_arm64' => 'android-arm64-v8a.apk',
  'android_arm' => 'android-armeabi-v7a.apk',
  'android_x64' => 'android-x86_64.apk',
  'windows_x64' => 'windows-x64.zip',
  'macos_arm64' || 'macos_x64' => 'macos.dmg',
  'linux_x64' => 'linux-x64.tar.gz',
  _ => null,
};

/// The release file built for [platform], or null.
UpdateAsset? pickAsset(Iterable<UpdateAsset> assets, String platform) {
  final suffix = assetSuffixFor(platform);
  if (suffix == null) return null;
  for (final asset in assets) {
    if (asset.name.toLowerCase().endsWith(suffix)) return asset;
  }
  return null;
}

/// Release notes as plain text for the update dialog: stops at the `---` that
/// starts the standard download footer, turns headings into plain lines and
/// bullets into `•`, and drops bold and code marks.
String formatReleaseNotes(String markdown, {int maxLength = 2500}) {
  final lines = <String>[];
  for (var line in markdown.replaceAll('\r\n', '\n').split('\n')) {
    line = line.trimRight();
    if (line.trim() == '---') break;
    if (line.trim().isEmpty) {
      if (lines.isNotEmpty && lines.last.isNotEmpty) lines.add('');
      continue;
    }

    final heading = RegExp(r'^#{1,6}\s*(.+)$').firstMatch(line.trim());
    if (heading != null) {
      if (lines.isNotEmpty && lines.last.isNotEmpty) lines.add('');
      lines.add(_plain(heading.group(1)!));
      continue;
    }
    final bullet = RegExp(r'^\s*[-*]\s+(.+)$').firstMatch(line);
    lines.add(bullet != null ? '• ${_plain(bullet.group(1)!)}' : _plain(line));
  }
  final text = lines.join('\n').trim();
  return text.length <= maxLength ? text : '${text.substring(0, maxLength)}…';
}

String _plain(String s) => s
    .replaceAllMapped(RegExp(r'\*\*([^*]+)\*\*'), (m) => m[1]!)
    .replaceAllMapped(RegExp(r'\*([^*\s][^*]*)\*'), (m) => m[1]!)
    .replaceAllMapped(RegExp(r'`([^`]+)`'), (m) => m[1]!)
    .replaceAllMapped(RegExp(r'\[([^\]]+)\]\([^)]+\)'), (m) => m[1]!);
