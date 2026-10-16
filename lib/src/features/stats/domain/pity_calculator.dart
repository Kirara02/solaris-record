import 'pool_type.dart';

const hardPity5 = 80;
const hardPity4 = 10;

/// Standard-pool 5★ Resonators (English names). Getting one from the featured
/// resonator banner means the 50/50 was lost. Records are always fetched with
/// the `en` language code so these names match.
const standardFiveStarResonators = {
  'Verina',
  'Encore',
  'Calcharo',
  'Lingyang',
  'Jianxin',
};

/// One pull, in chronological order.
class Pull {
  const Pull({
    required this.name,
    required this.rarity,
    required this.time,
    this.resourceId = 0,
    this.resourceType = '',
  });

  final String name;
  final int rarity;
  final String time;
  final int resourceId;
  final String resourceType;
}

enum FiftyFiftyResult { won, lost, guaranteed, notApplicable }

class FiveStarEntry {
  const FiveStarEntry({
    required this.name,
    required this.time,
    required this.pullsUsed,
    required this.result,
    this.resourceId = 0,
    this.resourceType = '',
  });

  final String name;
  final String time;

  /// Pulls spent since the previous 5★ (inclusive of this one).
  final int pullsUsed;
  final FiftyFiftyResult result;
  final int resourceId;
  final String resourceType;
}

class PoolStats {
  const PoolStats({
    required this.total,
    required this.fiveStars,
    required this.fourStars,
    required this.threeStars,
    required this.pity5,
    required this.pity4,
    required this.averagePullsPerFiveStar,
    required this.averagePullsPerFourStar,
    required this.fiveStarHistory,
    required this.nextFiveStarGuaranteed,
  });

  final int total;
  final int fiveStars;
  final int fourStars;
  final int threeStars;

  /// Pulls since the last 5★.
  final int pity5;

  /// Pulls since the last 4★ or better.
  final int pity4;
  final double? averagePullsPerFiveStar;

  /// Average pulls between 4★-or-better hits (a 5★ also resets the 4★ pity,
  /// so both end a segment). Excludes the still-running segment.
  final double? averagePullsPerFourStar;

  /// Oldest first.
  final List<FiveStarEntry> fiveStarHistory;

  /// True when the next 5★ is guaranteed to be the featured one.
  final bool nextFiveStarGuaranteed;

  int get fiftyFiftyWon =>
      fiveStarHistory.where((e) => e.result == FiftyFiftyResult.won).length;
  int get fiftyFiftyLost =>
      fiveStarHistory.where((e) => e.result == FiftyFiftyResult.lost).length;
}

/// [pulls] must be in chronological order (oldest first).
PoolStats calculatePoolStats(PoolType pool, List<Pull> pulls) {
  var fives = 0, fours = 0, threes = 0;
  var pity5 = 0, pity4 = 0;
  var guaranteed = false;
  final history = <FiveStarEntry>[];

  for (final pull in pulls) {
    pity5++;
    pity4++;
    switch (pull.rarity) {
      case 5:
        fives++;
        var result = FiftyFiftyResult.notApplicable;
        if (pool.hasFiftyFifty) {
          if (guaranteed) {
            result = FiftyFiftyResult.guaranteed;
            guaranteed = false;
          } else if (standardFiveStarResonators.contains(pull.name)) {
            result = FiftyFiftyResult.lost;
            guaranteed = true;
          } else {
            result = FiftyFiftyResult.won;
          }
        }
        history.add(
          FiveStarEntry(
            name: pull.name,
            time: pull.time,
            pullsUsed: pity5,
            result: result,
            resourceId: pull.resourceId,
            resourceType: pull.resourceType,
          ),
        );
        pity5 = 0;
        pity4 = 0;
      case 4:
        fours++;
        pity4 = 0;
      default:
        threes++;
    }
  }

  final spent = history.fold<int>(0, (sum, e) => sum + e.pullsUsed);
  return PoolStats(
    total: pulls.length,
    fiveStars: fives,
    fourStars: fours,
    threeStars: threes,
    pity5: pity5,
    pity4: pity4,
    averagePullsPerFiveStar: history.isEmpty ? null : spent / history.length,
    averagePullsPerFourStar: fours + fives == 0
        ? null
        : (pulls.length - pity4) / (fours + fives),
    fiveStarHistory: history,
    nextFiveStarGuaranteed: guaranteed,
  );
}
