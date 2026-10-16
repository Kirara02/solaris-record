import 'package:flutter_test/flutter_test.dart';
import 'package:solaris_record_app/src/features/stats/domain/pity_calculator.dart';
import 'package:solaris_record_app/src/features/stats/domain/pool_type.dart';

List<Pull> pulls(List<int> rarities, {Map<int, String> names = const {}}) => [
  for (var i = 0; i < rarities.length; i++)
    Pull(
      name: names[i] ?? 'Item$i',
      rarity: rarities[i],
      time: '2024-01-01 00:00:${i.toString().padLeft(2, '0')}',
    ),
];

void main() {
  test('5★ exactly at pull 80 resets pity', () {
    final r = [for (var i = 0; i < 79; i++) 3, 5];
    final s = calculatePoolStats(PoolType.featuredWeapon, pulls(r));
    expect(s.total, 80);
    expect(s.fiveStars, 1);
    expect(s.fiveStarHistory.single.pullsUsed, 80);
    expect(s.pity5, 0);
    expect(s.averagePullsPerFiveStar, 80);
  });

  test('pity counts pulls since last 5★', () {
    final r = [3, 3, 5, 3, 3, 3];
    final s = calculatePoolStats(PoolType.standardWeapon, pulls(r));
    expect(s.pity5, 3);
    expect(s.fiveStarHistory.single.pullsUsed, 3);
  });

  test('4★ at pull 10 resets 4★ pity; 5★ also resets it', () {
    var s = calculatePoolStats(
      PoolType.standardWeapon,
      pulls([for (var i = 0; i < 9; i++) 3, 4, 3]),
    );
    expect(s.fourStars, 1);
    expect(s.pity4, 1);
    s = calculatePoolStats(PoolType.standardWeapon, pulls([3, 3, 5, 3]));
    expect(s.pity4, 1);
  });

  test('50/50: win, loss, then guaranteed', () {
    final s = calculatePoolStats(
      PoolType.featuredResonator,
      pulls([5, 5, 5, 3], names: {0: 'Jinhsi', 1: 'Verina', 2: 'Changli'}),
    );
    expect(s.fiveStarHistory.map((e) => e.result), [
      FiftyFiftyResult.won,
      FiftyFiftyResult.lost,
      FiftyFiftyResult.guaranteed,
    ]);
    expect(s.nextFiveStarGuaranteed, isFalse);
    expect(s.fiftyFiftyWon, 1);
    expect(s.fiftyFiftyLost, 1);
  });

  test('guarantee flag is pending after a loss', () {
    final s = calculatePoolStats(
      PoolType.featuredResonator,
      pulls([5], names: {0: 'Encore'}),
    );
    expect(s.nextFiveStarGuaranteed, isTrue);
  });

  test('no 50/50 outside featured resonator banner', () {
    final s = calculatePoolStats(
      PoolType.featuredWeapon,
      pulls([5], names: {0: 'Verina'}),
    );
    expect(s.fiveStarHistory.single.result, FiftyFiftyResult.notApplicable);
  });

  test('empty history', () {
    final s = calculatePoolStats(PoolType.beginner, const []);
    expect(s.total, 0);
    expect(s.averagePullsPerFiveStar, isNull);
  });

  group('average pulls per 4★-or-better', () {
    test('excludes the running segment and counts 5★ as a hit', () {
      // pulls: 3 3 4 | 3 3 3 5 | 3 3 (running 2)
      final stats = calculatePoolStats(
        PoolType.standardWeapon,
        pulls([3, 3, 4, 3, 3, 3, 5, 3, 3]),
      );
      expect(stats.pity4, 2);
      // (9 total - 2 running) / (1 four + 1 five) = 3.5
      expect(stats.averagePullsPerFourStar, 3.5);
    });

    test('null until the first hit', () {
      final stats = calculatePoolStats(
        PoolType.standardWeapon,
        pulls([3, 3, 3]),
      );
      expect(stats.averagePullsPerFourStar, isNull);
    });
  });
}
