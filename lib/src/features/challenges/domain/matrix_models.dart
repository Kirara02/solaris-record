import 'package:flutter/painting.dart' show Color;

import 'challenge_text.dart';

String? _url(Object? v) => v is String && v.startsWith('http') ? v : null;

int _int(Object? v) => v is num ? v.round() : 0;

/// "rrggbb" or "rrggbbaa" (alpha last) as an opaque colour, as the web page
/// does (it ignores the alpha).
Color? _rgb(Object? v) {
  if (v is! String) return null;
  final hex = v.replaceFirst('#', '');
  if (hex.length != 6 && hex.length != 8) return null;
  final n = int.tryParse(hex.substring(0, 6), radix: 16);
  return n == null ? null : Color(0xFF000000 | n);
}

/// A buff of the whole level (name, icon, effect).
class MatrixBuff {
  const MatrixBuff(this.name, this.description, {this.iconUrl});

  final String name;

  /// Game markup (see `MarkupText`).
  final String description;
  final String? iconUrl;
}

class MatrixScore {
  const MatrixScore(this.value, {this.iconUrl});

  final int value;
  final String? iconUrl;
}

class MatrixTag {
  const MatrixTag(this.name, {this.iconUrl, this.color});

  final String name;
  final String? iconUrl;
  final Color? color;
}

/// An escalation the boss triggers, or a suggested buff (no description).
class MatrixSkill {
  const MatrixSkill(this.title, {this.description, this.iconUrl, this.color});

  final String title;
  final String? description;
  final String? iconUrl;
  final Color? color;
}

class MatrixWave {
  const MatrixWave({
    required this.id,
    required this.round,
    required this.wave,
    required this.name,
    this.description,
    this.imageUrl,
    this.tags = const [],
    this.escalations = const [],
    this.suggested = const [],
  });

  final int id;
  final int round;
  final int wave;
  final String name;
  final String? description;

  /// Boss art.
  final String? imageUrl;
  final List<MatrixTag> tags;
  final List<MatrixSkill> escalations;
  final List<MatrixSkill> suggested;
}

class MatrixLevel {
  const MatrixLevel({
    required this.id,
    required this.name,
    this.buffs = const [],
    this.scores = const [],
    this.waves = const [],
  });

  final int id;
  final String name;
  final List<MatrixBuff> buffs;
  final List<MatrixScore> scores;
  final List<MatrixWave> waves;

  /// The rounds present in [waves], ascending (one means no round tabs).
  List<int> get rounds => ({for (final w in waves) w.round}.toList()..sort());
}

class MatrixRole {
  const MatrixRole(this.name, {this.iconUrl, this.skills = const []});

  final String name;
  final String? iconUrl;

  /// Game markup, one entry per enhanced skill.
  final List<String> skills;
}

class MatrixSeason {
  const MatrixSeason(this.levels, this.roles);

  final List<MatrixLevel> levels;
  final List<MatrixRole> roles;
}

const _tagColors = {
  1: 0xFF41AEFB,
  2: 0xFFF0744E,
  3: 0xFFB46BFF,
  4: 0xFF55FFB5,
  5: 0xFFF8E56C,
  6: 0xFFC98BB3,
};

MatrixWave? _wave(Object? raw) {
  if (raw is! Map) return null;
  final name = textOf(raw['Name']);
  if (name == null) return null;
  return MatrixWave(
    id: _int(raw['Id']),
    round: raw['Round'] is num ? _int(raw['Round']) : 1,
    wave: _int(raw['Wave']),
    name: name,
    description: rawOf(raw['Desc']),
    imageUrl: _url(raw['Icon']),
    tags: [
      for (final t in listOf(raw['Tags']))
        if (t is Map && textOf(t['Name']) != null)
          MatrixTag(
            textOf(t['Name'])!,
            iconUrl: _url(t['Path']),
            color:
                _rgb(t['Color']) ??
                (_tagColors[t['Id']] == null
                    ? null
                    : Color(_tagColors[t['Id']]!)),
          ),
    ],
    escalations: [
      for (final b in listOf(raw['ShowBuffIds']))
        if (b is Map && textOf(b['SkillTitle']) != null)
          MatrixSkill(
            textOf(b['SkillTitle'])!,
            description: textOf(b['SkillDesc']),
            iconUrl: _url(b['SmallIcon']) ?? _url(b['SkillIcon']),
            color: _rgb(b['BuffColor']),
          ),
    ],
    suggested: [
      for (final f in listOf(raw['RecommendTeamFeature']))
        if (f is Map && textOf(f['Name']) != null)
          MatrixSkill(textOf(f['Name'])!, iconUrl: _url(f['Icon'])),
    ],
  );
}

MatrixLevel? _level(Object? raw) {
  if (raw is! Map) return null;
  final waves = [for (final w in listOf(raw['Waves'])) ?_wave(w)]
    ..sort((a, b) => a.wave.compareTo(b.wave));
  return MatrixLevel(
    id: _int(raw['Id']),
    name: textOf(raw['Name']) ?? '${raw['Id']}',
    buffs: [
      for (final b in listOf(raw['NewTowerBuffs']))
        if (b is Map && textOf(b['Name']) != null)
          MatrixBuff(
            textOf(b['Name'])!,
            rawOf(b['Desc']) ?? '',
            iconUrl: _url(b['Icon']),
          ),
    ],
    scores: [
      for (final s in listOf(raw['ScoreLevelRule']))
        if (s is Map && s['Value'] is num)
          MatrixScore(_int(s['Value']), iconUrl: _url(s['Icon'])),
    ],
    waves: waves,
  );
}

MatrixSeason parseMatrixSeason(Object? json) {
  if (json is! Map) return const MatrixSeason([], []);
  return MatrixSeason(
    [for (final l in listOf(json['Levels'])) ?_level(l)],
    [
      for (final r in listOf(json['Roles']))
        if (r is Map &&
            r['RoleInfo'] is Map &&
            textOf(r['RoleInfo']['Name']) != null)
          MatrixRole(
            textOf(r['RoleInfo']['Name'])!,
            iconUrl: _url(r['RoleInfo']['RoleHeadIcon']),
            skills: [
              for (final d in listOf(r['EnhanceSkillDesc']))
                if (d is Map && rawOf(d['Value']) != null) rawOf(d['Value'])!,
            ],
          ),
    ],
  );
}
