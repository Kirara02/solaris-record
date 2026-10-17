import '../../update/domain/update_info.dart';

/// A notice from the developer, shown once in a dialog.
class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    this.ctaLabel,
    this.ctaUrl,
    this.minVersion,
    this.maxVersion,
    this.platforms = const [],
    this.expires,
  });

  /// Stable identifier; once dismissed an id is never shown again.
  final String id;

  /// Text per language code (`en` is the fallback).
  final Map<String, String> title;
  final Map<String, String> body;
  final Map<String, String>? ctaLabel;

  /// An https link for the button, or null for a plain notice.
  final String? ctaUrl;

  /// Installed versions this applies to, inclusive; either end can be open.
  final String? minVersion;
  final String? maxVersion;

  /// Operating systems (`android`, `ios`, `windows`, `macos`, `linux`) it
  /// applies to; empty means all.
  final List<String> platforms;
  final DateTime? expires;

  /// Whether it should be shown to [version] on [platform] at [now].
  bool appliesTo({
    required String version,
    required String platform,
    required DateTime now,
  }) {
    if (expires != null && !now.isBefore(expires!)) return false;
    if (platforms.isNotEmpty && !platforms.contains(platform)) return false;
    if (minVersion != null && isNewerVersion(minVersion!, version)) {
      return false;
    }
    if (maxVersion != null && isNewerVersion(version, maxVersion!)) {
      return false;
    }
    return true;
  }
}

/// [values] in [lang], else English, else any; null when empty.
String? pickText(Map<String, String>? values, String lang) {
  if (values == null || values.isEmpty) return null;
  return values[lang] ?? values['en'] ?? values.values.first;
}

Map<String, String>? _text(Object? raw) {
  if (raw is String && raw.trim().isNotEmpty) return {'en': raw.trim()};
  if (raw is Map) {
    final out = <String, String>{
      for (final e in raw.entries)
        if (e.key is String &&
            e.value is String &&
            (e.value as String).trim().isNotEmpty)
          e.key as String: (e.value as String).trim(),
    };
    return out.isEmpty ? null : out;
  }
  return null;
}

/// Reads `{"announcements": [...]}`. Entries without an id, a title or a body
/// are skipped, and a link that isn't https is dropped (the notice stays).
List<Announcement> parseAnnouncements(Object? json) {
  if (json is! Map) return const [];
  final list = json['announcements'];
  if (list is! List) return const [];
  final out = <Announcement>[];
  for (final raw in list) {
    if (raw is! Map) continue;
    final id = raw['id'];
    final title = _text(raw['title']);
    final body = _text(raw['body']);
    if (id is! String || id.isEmpty || title == null || body == null) continue;
    final url = raw['ctaUrl'];
    final https = url is String && Uri.tryParse(url)?.scheme == 'https';
    out.add(
      Announcement(
        id: id,
        title: title,
        body: body,
        ctaLabel: https ? _text(raw['ctaLabel']) : null,
        ctaUrl: https ? url : null,
        minVersion: raw['minVersion'] as String?,
        maxVersion: raw['maxVersion'] as String?,
        platforms: [
          for (final p in (raw['platforms'] as List?) ?? const [])
            if (p is String) p,
        ],
        expires: DateTime.tryParse((raw['expires'] as String?) ?? ''),
      ),
    );
  }
  return out;
}
