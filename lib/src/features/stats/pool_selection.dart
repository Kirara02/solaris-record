import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'domain/pool_type.dart';

part 'pool_selection.g.dart';

/// What the Convene screen shows: one pull type, or `null` for the global
/// overview. Shared so the wide layout's navigation rail, the phone's
/// Overview / Convene tabs and the screen's own selector stay in sync.
@Riverpod(keepAlive: true)
class SelectedPool extends _$SelectedPool {
  @override
  PoolType? build() => null;

  /// The last pull type shown, so the phone's Convene tab reopens it after a
  /// visit to the Overview tab.
  PoolType _lastPool = PoolType.values.first;

  void select(PoolType? pool) {
    if (pool != null) _lastPool = pool;
    state = pool;
  }

  /// Switches to the Convene view (the last pull type).
  void selectConvene() => state = _lastPool;
}
