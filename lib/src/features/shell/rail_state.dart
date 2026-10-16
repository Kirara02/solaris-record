import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../stats/domain/pool_type.dart';

part 'rail_state.g.dart';

/// Whether the "Pull types" group in the rail is open (it can be collapsed).
@Riverpod(keepAlive: true)
class PoolGroupExpanded extends _$PoolGroupExpanded {
  @override
  bool build() => true;

  void toggle() => state = !state;
}

/// Flattened index of the highlighted rail entry: 0 is Overview, 1.. are the
/// pull types when their group is open.
///
/// -1 (nothing in the list) when a bottom item is active, and also when a pull
/// type is shown while its group is collapsed: the screen is not the overview,
/// so Overview must not look selected. The collapsed group's header names the
/// active pull type instead.
int railSelectedIndex({
  required int branch,
  required bool groupVisible,
  required PoolType? pool,
}) {
  if (branch != 0) return -1;
  if (pool == null) return 0;
  return groupVisible ? 1 + pool.index : -1;
}

/// App version for the rail's brand header ("1.0.0"), or null when it can't be
/// read (e.g. in tests, where the platform plugin is missing).
@Riverpod(keepAlive: true)
Future<String?> appVersion(Ref ref) async {
  try {
    return (await PackageInfo.fromPlatform()).version;
  } on Object {
    return null;
  }
}
