import 'challenge_text.dart';

/// One season of a recurring challenge mode. Season 0 (no dates) is the
/// permanent set.
class ChallengeSeason {
  const ChallengeSeason(
    this.id,
    this.name, {
    this.start,
    this.finish,
    this.group,
    this.endVersion,
  });

  final int id;
  final String name;

  /// The cycle a season belongs to (Endstate Matrix: "Adversity Vanguard").
  final String? group;

  /// The game version a season ends with, for modes dated by version.
  final String? endVersion;
  final DateTime? start;

  /// The day the next season starts, so a season runs up to but not through it.
  final DateTime? finish;

  bool get hasDates => start != null && finish != null;

  bool isCurrent(DateTime now) =>
      hasDates && !now.isBefore(start!) && now.isBefore(finish!);

  bool isUpcoming(DateTime now) => start != null && now.isBefore(start!);
}

/// The season to open first: the one running now, else the latest that has
/// started, else the first one.
ChallengeSeason? defaultSeason(List<ChallengeSeason> seasons, DateTime now) {
  if (seasons.isEmpty) return null;
  for (final s in seasons) {
    if (s.isCurrent(now)) return s;
  }
  final started = [
    for (final s in seasons)
      if (s.hasDates && !s.isUpcoming(now)) s,
  ];
  if (started.isNotEmpty) return started.last;
  // Undated lists (Endstate Matrix) end with the newest.
  return seasons.any((s) => s.hasDates) ? seasons.first : seasons.last;
}

/// Tower of Adversity lists `{seasons: [{id, name, start, finish}]}`;
/// Whimpering Wastes lists a bare array with `Season` instead of `id`.
List<ChallengeSeason> parseSeasons(Object? json) {
  final raw = json is Map ? json['seasons'] : json;
  final out = <ChallengeSeason>[];
  for (final e in listOf(raw)) {
    if (e is! Map) continue;
    final id = e['id'] ?? e['Season'];
    if (id is! int) continue;
    out.add(
      ChallengeSeason(
        id,
        textOf(e['name'] ?? e['Name']) ?? '$id',
        start: dateOf(e['start']),
        finish: dateOf(e['finish']),
      ),
    );
  }
  out.sort((a, b) => a.id.compareTo(b.id));
  return out;
}

/// Endstate Matrix lists `[{Season, Name, SeasonName, EndVersion}]`: seasons
/// have no dates, only the version they end with.
List<ChallengeSeason> parseMatrixSeasons(Object? json) {
  final out = <ChallengeSeason>[];
  for (final e in listOf(json)) {
    if (e is! Map || e['Season'] is! int) continue;
    out.add(
      ChallengeSeason(
        e['Season'] as int,
        textOf(e['Name']) ?? '${e['Season']}',
        group: textOf(e['SeasonName']),
        endVersion: textOf(e['EndVersion']),
      ),
    );
  }
  out.sort((a, b) => a.id.compareTo(b.id));
  return out;
}
