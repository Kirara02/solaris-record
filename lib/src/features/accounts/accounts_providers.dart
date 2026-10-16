import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/preferences.dart';
import '../../data/providers.dart';
import 'domain/account.dart';

part 'accounts_providers.g.dart';

@riverpod
Stream<List<Account>> accounts(Ref ref) =>
    ref.watch(conveneRepositoryProvider).watchAccounts();

/// UID of the selected account, persisted across restarts.
@Riverpod(keepAlive: true)
class ActiveUid extends _$ActiveUid {
  static const _key = 'active_uid';

  @override
  Future<String?> build() async =>
      (await SharedPreferences.getInstance()).getString(_key);

  Future<void> select(String? uid) async {
    final prefs = await SharedPreferences.getInstance();
    if (uid == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, uid);
    }
    state = AsyncData(uid);
  }
}

/// The selected account, falling back to the first one when the stored UID is
/// gone or unset. Null while loading or when there are no accounts.
@riverpod
Account? activeAccount(Ref ref) {
  final accounts = ref.watch(accountsProvider).value;
  final uid = ref.watch(activeUidProvider).value;
  if (accounts == null || accounts.isEmpty) return null;
  return accounts.firstWhere((a) => a.uid == uid, orElse: () => accounts.first);
}

/// Whether UIDs are shown as their first three digits only. On by default, so
/// screenshots of the app don't expose the account.
@Riverpod(keepAlive: true)
class MaskUid extends _$MaskUid {
  static const _key = 'mask_uid';

  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(_key) ?? true;

  Future<void> set(bool value) async {
    state = value;
    await ref.read(sharedPreferencesProvider).setBool(_key, value);
  }
}
