import 'package:flutter_test/flutter_test.dart';
import 'package:solaris_record_app/src/features/stats/domain/convene_record.dart';
import 'package:solaris_record_app/src/features/stats/domain/history_view.dart';

ConveneRecord rec(int i, int rarity) => ConveneRecord(
  uid: '1',
  poolType: 1,
  time: '2025-01-01 00:00:${i.toString().padLeft(2, '0')}',
  name: 'Item$i',
  resourceType: 'Weapon',
  rarity: rarity,
  count: 1,
  recordIndex: i,
);

void main() {
  // 70 pulls, oldest first: #10 and #55 are 5★, every 10th (other) is 4★.
  final chronological = [
    for (var i = 1; i <= 70; i++)
      rec(i, (i == 10 || i == 55) ? 5 : (i % 10 == 0 ? 4 : 3)),
  ];
  final entries = numberedNewestFirst(chronological);

  test('numbers pulls oldest=1 and lists newest first', () {
    expect(entries.first.number, 70);
    expect(entries.first.record.name, 'Item70');
    expect(entries.last.number, 1);
  });

  test('rarity counts', () {
    final c = rarityCounts(entries);
    expect((c.all, c.five, c.four, c.three), (70, 2, 6, 62));
  });

  test('pages split 30/30/10 and clamp out-of-range pages', () {
    final first = paginateHistory(entries);
    expect((first.page, first.pageCount, first.items.length), (0, 3, 30));
    expect(first.items.first.number, 70);

    final last = paginateHistory(entries, page: 2);
    expect(last.items.length, 10);
    expect(last.items.last.number, 1);

    expect(paginateHistory(entries, page: 99).page, 2);
    expect(paginateHistory(entries, page: -4).page, 0);
  });

  test('filter keeps real pull numbers and resets paging bounds', () {
    final fives = paginateHistory(
      entries,
      filter: const HistoryFilter(rarities: {5}),
    );
    expect(fives.matching, 2);
    expect(fives.pageCount, 1);
    expect(fives.items.map((e) => e.number), [55, 10]);

    final fours = paginateHistory(
      entries,
      filter: const HistoryFilter(rarities: {4}),
    );
    expect(fours.items.map((e) => e.record.rarity), everyElement(4));

    final threes = paginateHistory(
      entries,
      filter: const HistoryFilter(rarities: {3}),
    );
    expect(threes.matching, 62);
    expect(threes.pageCount, 3);
    // A page beyond the filtered range clamps instead of going empty.
    expect(
      paginateHistory(
        entries,
        filter: const HistoryFilter(rarities: {5}),
        page: 2,
      ).page,
      0,
    );
  });

  test('empty history and empty filter result', () {
    final none = paginateHistory(const []);
    expect(none.matching, 0);
    expect(none.pageCount, 1);
    expect(none.items, isEmpty);
    final noFives = paginateHistory(
      numberedNewestFirst([rec(1, 3)]),
      filter: const HistoryFilter(rarities: {5}),
    );
    expect(noFives.matching, 0);
  });

  test('exact multiple of page size does not add an empty page', () {
    final exact = numberedNewestFirst([
      for (var i = 1; i <= 60; i++) rec(i, 3),
    ]);
    expect(paginateHistory(exact).pageCount, 2);
  });

  group('HistoryFilter', () {
    ConveneRecord named(int i, String name, int rarity, String type) =>
        ConveneRecord(
          uid: '1',
          poolType: 1,
          time: '2025-01-01 00:00:${i.toString().padLeft(2, '0')}',
          name: name,
          resourceType: type,
          rarity: rarity,
          count: 1,
          recordIndex: i,
        );

    final mixed = numberedNewestFirst([
      named(1, 'Training Sword', 3, 'Weapon'),
      named(2, 'Jinhsi', 5, 'Resonator'),
      named(3, 'Danjin', 4, 'Resonator'),
      named(4, 'Sword of Night', 4, 'Weapon'),
      named(5, 'Verina', 5, 'Resonator'),
    ]);

    List<String> names(HistoryFilter f) => paginateHistory(
      mixed,
      filter: f,
    ).items.map((e) => e.record.name).toList();

    test('search is case-insensitive and matches anywhere in the name', () {
      expect(names(const HistoryFilter(query: 'SWORD')), [
        'Sword of Night',
        'Training Sword',
      ]);
      expect(names(const HistoryFilter(query: '  jin ')), ['Danjin', 'Jinhsi']);
      expect(names(const HistoryFilter(query: 'zzz')), isEmpty);
    });

    test('type filter matches the API resource type', () {
      expect(names(const HistoryFilter(types: {'Weapon'})), [
        'Sword of Night',
        'Training Sword',
      ]);
      expect(
        names(const HistoryFilter(types: {'weapon', 'RESONATOR'})),
        hasLength(5),
      );
    });

    test('rarity, type and search combine with AND; rarities with OR', () {
      expect(
        names(const HistoryFilter(rarities: {5, 4}, types: {'Resonator'})),
        ['Verina', 'Danjin', 'Jinhsi'],
      );
      expect(
        names(
          const HistoryFilter(
            rarities: {4},
            types: {'Resonator'},
            query: 'dan',
          ),
        ),
        ['Danjin'],
      );
    });

    test('oldest first reverses the filtered list and keeps pull numbers', () {
      final page = paginateHistory(
        mixed,
        filter: const HistoryFilter(newestFirst: false, rarities: {5}),
      );
      expect(page.items.map((e) => e.number), [2, 5]);
    });

    test('dialogCount ignores the search text', () {
      expect(const HistoryFilter(query: 'x').dialogCount, 0);
      expect(const HistoryFilter(query: 'x').hasAny, isTrue);
      expect(
        const HistoryFilter(
          rarities: {5},
          types: {'Weapon'},
          newestFirst: false,
        ).dialogCount,
        3,
      );
      expect(const HistoryFilter().hasAny, isFalse);
    });

    test('typeCounts lists distinct types, most common first', () {
      expect(typeCounts(mixed), [('Resonator', 3), ('Weapon', 2)]);
    });
  });
}
