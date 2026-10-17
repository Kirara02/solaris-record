/// Parameters extracted from an in-game convene record URL.
class ConveneUrl {
  const ConveneUrl({
    required this.serverId,
    required this.playerId,
    required this.recordId,
    required this.language,
    this.cardPoolId,
    this.gachaId,
    this.gachaType,
  });

  final String serverId;
  final String playerId;
  final String recordId;
  final String language;
  final String? cardPoolId;
  final String? gachaId;
  final String? gachaType;

  /// Value sent as `cardPoolId` (the URL's `resources_id`).
  String get poolIdParam => cardPoolId ?? gachaId ?? '1';
}

class ConveneUrlException implements Exception {
  const ConveneUrlException(this.missing);

  /// Names of the missing parameters, or empty when the URL is unparsable.
  final List<String> missing;

  @override
  String toString() => 'ConveneUrlException(missing: $missing)';
}

/// Parses URLs like
/// `https://.../aki/gacha/index.html#/record?svr_id=..&player_id=..&record_id=..`.
/// Parameters are read from the fragment, falling back to the normal query.
ConveneUrl parseConveneUrl(String input) {
  final text = input.trim();
  final uri = Uri.tryParse(text);
  if (uri == null || !uri.hasScheme) {
    throw const ConveneUrlException([]);
  }

  final params = <String, String>{...uri.queryParameters};
  final fragment = uri.fragment;
  final q = fragment.indexOf('?');
  if (q >= 0) {
    params.addAll(Uri.splitQueryString(fragment.substring(q + 1)));
  }

  const required = ['svr_id', 'player_id', 'record_id'];
  final missing = [
    for (final key in required)
      if ((params[key] ?? '').isEmpty) key,
  ];
  if (missing.isNotEmpty) throw ConveneUrlException(missing);

  return ConveneUrl(
    serverId: params['svr_id']!,
    playerId: params['player_id']!,
    recordId: params['record_id']!,
    language: params['lang'] ?? 'en',
    cardPoolId: params['resources_id'],
    gachaId: params['gacha_id'],
    gachaType: params['gacha_type'],
  );
}

/// The first convene record URL in [text], or null. Shared text often has a
/// title or a few words around the link, and may end in punctuation.
String? extractConveneUrl(String text) {
  for (final match in RegExp(r'https?://[^\s<>"]+').allMatches(text)) {
    final url = match.group(0)!.replaceFirst(RegExp(r'[.,;:!?)\]}]+$'), '');
    try {
      parseConveneUrl(url);
      return url;
    } on ConveneUrlException {
      continue;
    }
  }
  return null;
}
