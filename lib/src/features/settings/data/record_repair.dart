import '../../../data/convene_repository.dart';
import '../../guide/data/guide_service.dart';
import '../../guide/domain/guide_entry.dart';

/// What a repair did.
class RepairReport {
  const RepairReport({required this.fixed, required this.remaining});

  /// Records that got their item id.
  final int fixed;

  /// Records that still have none (no item of that name, or several).
  final int remaining;

  bool get nothingToDo => fixed == 0 && remaining == 0;
}

/// Records imported without an item id (a WuWa Tracker export can lack them)
/// get no icon and no details. The convene API only returns a recent window,
/// so a URL import never fills the old ones in. This looks each name up in
/// encore.moe's resonator and weapon lists (the English names the records are
/// stored with) and fills in the id and type.
///
/// Additive: it only fills a missing id, never replaces one, and never
/// deletes. A name that more than one item carries (the four Rovers) is left
/// alone rather than guessed.
class RecordRepair {
  RecordRepair(this._repository, this._guide);

  final ConveneRepository _repository;
  final GuideService _guide;

  static String _key(String name) => name
      .replaceAll('\u2019', "'")
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .toLowerCase();

  Future<RepairReport> run() async {
    final names = await _repository.namesWithoutResourceId();
    if (names.isEmpty) return const RepairReport(fixed: 0, remaining: 0);

    final byName = <String, GuideEntry?>{};
    final types = <int, String>{};
    for (final (kind, type) in [
      (GuideKind.resonator, 'Resonator'),
      (GuideKind.weapon, 'Weapon'),
    ]) {
      for (final e in await _guide.list(kind, 'en')) {
        final key = _key(e.name);
        // A second item with the same name makes the name ambiguous.
        byName[key] = byName.containsKey(key) ? null : e;
        types[e.id] = type;
      }
    }

    var fixed = 0;
    for (final name in names) {
      final entry = byName[_key(name)];
      if (entry == null) continue;
      fixed += await _repository.fillResourceId(
        name: name,
        resourceId: entry.id,
        resourceType: types[entry.id]!,
      );
    }
    return RepairReport(
      fixed: fixed,
      remaining: await _repository.countWithoutResourceId(),
    );
  }
}
