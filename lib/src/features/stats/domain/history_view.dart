import 'convene_record.dart';

/// A record with its 1-based pull number within the pool (oldest = #1) and its
/// pity: the pulls since the previous 5★, counting this one (a 5★ shows how
/// many pulls it took).
class HistoryEntry {
  const HistoryEntry(this.record, this.number, this.pity);

  final ConveneRecord record;
  final int number;
  final int pity;
}

/// One page of the (optionally filtered) history, newest first.
class HistoryPage {
  const HistoryPage({
    required this.items,
    required this.page,
    required this.pageCount,
    required this.matching,
  });

  final List<HistoryEntry> items;

  /// 0-based, already clamped to the valid range.
  final int page;
  final int pageCount;

  /// Entries matching the filter, across all pages.
  final int matching;
}

const historyPageSize = 30;

/// Numbers [chronological] records (oldest first) and returns them newest
/// first. Numbers are assigned before filtering so a 5★ keeps its real pull
/// number when other rarities are hidden.
List<HistoryEntry> numberedNewestFirst(List<ConveneRecord> chronological) {
  final entries = <HistoryEntry>[];
  var pity = 0;
  for (var i = 0; i < chronological.length; i++) {
    pity++;
    entries.add(HistoryEntry(chronological[i], i + 1, pity));
    if (chronological[i].rarity >= 5) pity = 0;
  }
  return entries.reversed.toList();
}

/// Per-rarity counts for the filter chips (`all` is the total).
({int all, int five, int four, int three}) rarityCounts(
  List<HistoryEntry> entries,
) {
  var five = 0, four = 0;
  for (final e in entries) {
    if (e.record.rarity == 5) {
      five++;
    } else if (e.record.rarity == 4) {
      four++;
    }
  }
  return (
    all: entries.length,
    five: five,
    four: four,
    three: entries.length - five - four,
  );
}

/// Column the history is sorted by.
enum HistorySortField {
  time,
  name,
  type,
  rarity,
  pity;

  /// Direction a column starts in: text reads A–Z, the rest biggest first.
  bool get startsDescending => this != name && this != type;
}

/// What the History list shows: a name search plus rarity / type filters and
/// the sort column and direction. Empty sets mean "no restriction".
class HistoryFilter {
  const HistoryFilter({
    this.query = '',
    this.rarities = const {},
    this.types = const {},
    this.sortField = HistorySortField.time,
    this.newestFirst = true,
  });

  final String query;

  /// Any of 5, 4, 3 (3 means everything below 4★).
  final Set<int> rarities;

  /// API `resourceType` values (e.g. "Resonator", "Weapon").
  final Set<String> types;
  final HistorySortField sortField;

  /// Descending order: newest first for [HistorySortField.time], biggest or
  /// Z–A first for the other columns.
  final bool newestFirst;

  bool get isDefaultSort => sortField == HistorySortField.time && newestFirst;

  /// How many options of the filter dialog are set (search not included).
  int get dialogCount =>
      (rarities.isEmpty ? 0 : 1) +
      (types.isEmpty ? 0 : 1) +
      (isDefaultSort ? 0 : 1);

  bool get hasAny => query.trim().isNotEmpty || dialogCount > 0;

  HistoryFilter copyWith({
    String? query,
    Set<int>? rarities,
    Set<String>? types,
    HistorySortField? sortField,
    bool? newestFirst,
  }) => HistoryFilter(
    query: query ?? this.query,
    rarities: rarities ?? this.rarities,
    types: types ?? this.types,
    sortField: sortField ?? this.sortField,
    newestFirst: newestFirst ?? this.newestFirst,
  );

  /// Whether [r] passes the filters. The search matches the stored English
  /// name and, when [nameOf] is given, the name shown to the user.
  bool matches(ConveneRecord r, {String Function(ConveneRecord)? nameOf}) {
    if (rarities.isNotEmpty) {
      final bucket = r.rarity >= 5
          ? 5
          : r.rarity == 4
          ? 4
          : 3;
      if (!rarities.contains(bucket)) return false;
    }
    if (types.isNotEmpty &&
        !types.any((t) => t.toLowerCase() == r.resourceType.toLowerCase())) {
      return false;
    }
    final q = query.trim().toLowerCase();
    if (q.isEmpty || r.name.toLowerCase().contains(q)) return true;
    return nameOf != null && nameOf(r).toLowerCase().contains(q);
  }
}

/// Distinct item types in [entries] with their counts, most common first.
List<(String, int)> typeCounts(List<HistoryEntry> entries) {
  final counts = <String, int>{};
  for (final e in entries) {
    final type = e.record.resourceType;
    if (type.isNotEmpty) counts[type] = (counts[type] ?? 0) + 1;
  }
  return counts.entries.map((e) => (e.key, e.value)).toList()
    ..sort((a, b) => b.$2.compareTo(a.$2));
}

/// Applies [filter] (and its sort direction) to [entries] (newest first) and
/// slices the requested [page], clamping it into range.
HistoryPage paginateHistory(
  List<HistoryEntry> entries, {
  HistoryFilter filter = const HistoryFilter(),
  int page = 0,
  int pageSize = historyPageSize,
  String Function(ConveneRecord)? nameOf,
}) {
  var filtered = filter.hasAny
      ? [
          for (final e in entries)
            if (filter.matches(e.record, nameOf: nameOf)) e,
        ]
      : entries;
  filtered = _sorted(filtered, filter, nameOf);
  final pageCount = filtered.isEmpty ? 1 : (filtered.length / pageSize).ceil();
  final clamped = page.clamp(0, pageCount - 1);
  final start = clamped * pageSize;
  final end = (start + pageSize).clamp(0, filtered.length);
  return HistoryPage(
    items: filtered.sublist(start, end),
    page: clamped,
    pageCount: pageCount,
    matching: filtered.length,
  );
}

int _compareBy(
  HistorySortField field,
  HistoryEntry a,
  HistoryEntry b,
  String Function(ConveneRecord) nameOf,
) => switch (field) {
  HistorySortField.time => a.number.compareTo(b.number),
  HistorySortField.name => nameOf(
    a.record,
  ).toLowerCase().compareTo(nameOf(b.record).toLowerCase()),
  HistorySortField.type => a.record.resourceType.toLowerCase().compareTo(
    b.record.resourceType.toLowerCase(),
  ),
  HistorySortField.rarity => a.record.rarity.compareTo(b.record.rarity),
  HistorySortField.pity => a.pity.compareTo(b.pity),
};

/// [entries] (newest first) in the filter's sort order. Ties fall back to the
/// newest pull first, so equal rows stay in a stable, readable order.
List<HistoryEntry> _sorted(
  List<HistoryEntry> entries,
  HistoryFilter filter,
  String Function(ConveneRecord)? nameOf,
) {
  if (filter.sortField == HistorySortField.time) {
    return filter.newestFirst ? entries : entries.reversed.toList();
  }
  return [...entries]..sort((a, b) {
    final c = _compareBy(filter.sortField, a, b, nameOf ?? (r) => r.name);
    if (c != 0) return filter.newestFirst ? -c : c;
    return b.number.compareTo(a.number);
  });
}
