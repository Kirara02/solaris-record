import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/preferences.dart';
import '../../data/providers.dart';

part 'repair_providers.g.dart';

const _ignoredKey = 'repair_ignored_count';

/// How many records still lacked an item id after the last repair. Those
/// cannot be matched (no item of that name, or several), so the warning stays
/// quiet about them until more incomplete records turn up.
@Riverpod(keepAlive: true)
class RepairIgnoredCount extends _$RepairIgnoredCount {
  @override
  int build() => ref.watch(sharedPreferencesProvider).getInt(_ignoredKey) ?? 0;

  Future<void> set(int value) async {
    state = value;
    await ref.read(sharedPreferencesProvider).setInt(_ignoredKey, value);
  }
}

/// Records without an item id that a repair may still fill in; 0 hides the
/// warning in the top bar.
@Riverpod(keepAlive: true)
int incompleteRecordWarning(Ref ref) {
  final count = ref
      .watch(incompleteRecordCountProvider)
      .maybeWhen(data: (n) => n, orElse: () => 0);
  return count > ref.watch(repairIgnoredCountProvider) ? count : 0;
}
