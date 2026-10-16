/// Hides all but the first three characters of a UID, for logs people share.
String sanitizeUid(String uid) =>
    uid.length <= 3 ? uid : '${uid.substring(0, 3)}***';

final _secretParams = RegExp(
  r'(record_id|svr_id|player_id|resources_id|gacha_id)=[^&#\s]*',
  caseSensitive: false,
);

/// Masks the identifying values of a convene record URL (record token, server,
/// player and pool ids) so it can be logged.
String sanitizeUrl(String url) =>
    url.replaceAllMapped(_secretParams, (m) => '${m[1]}=***');
