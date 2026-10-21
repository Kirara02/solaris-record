/// Plain text of encore.moe's game markup: `<br>` becomes a line break, other
/// tags (colour spans) are dropped.
String plainText(String raw) => raw
    .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
    .replaceAll(RegExp(r'<[^>]*>'), '')
    .replaceAll('&nbsp;', ' ')
    .replaceAll('&amp;', '&')
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .trim();

String? textOf(Object? v) {
  if (v is! String) return null;
  final t = plainText(v);
  return t.isEmpty ? null : t;
}

/// A list field read leniently: a list as is, a map as its values, else empty.
List<dynamic> listOf(Object? v) => switch (v) {
  List() => v,
  Map() => v.values.toList(),
  _ => const [],
};

DateTime? dateOf(Object? raw) {
  if (raw is! String) return null;
  final parsed = DateTime.tryParse(raw.trim());
  return parsed == null
      ? null
      : DateTime(parsed.year, parsed.month, parsed.day);
}

/// A string field kept as is (markup included), or null when empty.
String? rawOf(Object? v) {
  if (v is! String) return null;
  final t = v.trim();
  return t.isEmpty ? null : t;
}
