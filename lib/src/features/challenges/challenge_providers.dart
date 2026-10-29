import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'data/challenge_service.dart';
import 'domain/challenge_models.dart';
import 'domain/challenge_season.dart';
import 'domain/matrix_models.dart';
import 'domain/monster_info.dart';

part 'challenge_providers.g.dart';

final _log = Logger('challenges');

@Riverpod(keepAlive: true)
ChallengeService challengeService(Ref ref) => ChallengeService();

/// The challenge screens offer their own retry button, so don't retry
/// silently.
Duration? _noRetry(int retryCount, Object error) => null;

Future<T> _logged<T>(String what, Future<T> Function() load) async {
  try {
    return await load();
  } on Object catch (e, st) {
    _log.warning('$what failed', e, st);
    rethrow;
  }
}

@Riverpod(keepAlive: true, retry: _noRetry)
Future<List<ChallengeSeason>> towerSeasons(Ref ref, String lang) => _logged(
  'Tower seasons lang=$lang',
  () => ref.watch(challengeServiceProvider).towerSeasons(lang),
);

@Riverpod(keepAlive: true, retry: _noRetry)
Future<TowerSeason> towerSeason(Ref ref, int season, String lang) => _logged(
  'Tower season=$season lang=$lang',
  () => ref.watch(challengeServiceProvider).tower(season, lang),
);

@Riverpod(keepAlive: true, retry: _noRetry)
Future<List<ChallengeSeason>> whiwaSeasons(Ref ref, String lang) => _logged(
  'Whimpering Wastes seasons lang=$lang',
  () => ref.watch(challengeServiceProvider).whiwaSeasons(lang),
);

@Riverpod(keepAlive: true, retry: _noRetry)
Future<WhiwaSeason> whiwaSeason(Ref ref, int season, String lang) => _logged(
  'Whimpering Wastes season=$season lang=$lang',
  () => ref.watch(challengeServiceProvider).whiwa(season, lang),
);

@Riverpod(keepAlive: true, retry: _noRetry)
Future<WhiwaBuffInfo?> whiwaBuffInfo(Ref ref, int itemId, String lang) =>
    _logged(
      'Whimpering Wastes buff item=$itemId lang=$lang',
      () => ref.watch(challengeServiceProvider).buffInfo(itemId, lang),
    );

@Riverpod(keepAlive: true, retry: _noRetry)
Future<List<ChallengeSeason>> matrixSeasons(Ref ref, String lang) => _logged(
  'Endstate Matrix seasons lang=$lang',
  () => ref.watch(challengeServiceProvider).matrixSeasons(lang),
);

@Riverpod(keepAlive: true, retry: _noRetry)
Future<MatrixSeason> matrixSeason(Ref ref, int season, String lang) => _logged(
  'Endstate Matrix season=$season lang=$lang',
  () => ref.watch(challengeServiceProvider).matrix(season, lang),
);

@Riverpod(keepAlive: true, retry: _noRetry)
Future<MonsterInfo?> monsterInfo(Ref ref, int id, String lang) => _logged(
  'Monster id=$id lang=$lang',
  () => ref.watch(challengeServiceProvider).monster(id, lang),
);
