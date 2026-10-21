/// A redeem code from `redeem-codes.json`.
class RedeemCode {
  const RedeemCode({
    required this.code,
    this.rewards,
    this.source,
    this.added,
    this.expires,
    this.active = true,
  });

  final String code;

  /// Reward text per language code (`en` is the fallback).
  final Map<String, String>? rewards;
  final Map<String, String>? source;
  final DateTime? added;

  /// Last day the code works (inclusive), or null when it has no known end.
  final DateTime? expires;

  /// False once the maintainer marks the code as no longer working.
  final bool active;

  /// Whether the code no longer works at [now].
  bool isExpired(DateTime now) {
    if (!active) return true;
    final end = expires;
    if (end == null) return false;
    // `expires` is a date; the code works through that whole day.
    return now.isAfter(DateTime(end.year, end.month, end.day + 1));
  }
}

DateTime? _date(Object? raw) {
  if (raw is! String) return null;
  final parsed = DateTime.tryParse(raw.trim());
  return parsed == null
      ? null
      : DateTime(parsed.year, parsed.month, parsed.day);
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

/// Parses the file's `{"codes": [...]}`. Malformed entries and duplicate codes
/// are skipped; anything that isn't the expected shape gives an empty list.
List<RedeemCode> parseRedeemCodes(Object? json) {
  if (json is! Map) return const [];
  final raw = json['codes'];
  if (raw is! List) return const [];
  final seen = <String>{};
  final out = <RedeemCode>[];
  for (final e in raw) {
    if (e is! Map) continue;
    final code = e['code'];
    if (code is! String || code.trim().isEmpty) continue;
    final trimmed = code.trim();
    if (!seen.add(trimmed.toUpperCase())) continue;
    out.add(
      RedeemCode(
        code: trimmed,
        rewards: _text(e['rewards']),
        source: _text(e['source']),
        added: _date(e['added']),
        expires: _date(e['expires']),
        active: e['active'] != false,
      ),
    );
  }
  return out;
}
