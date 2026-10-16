// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accounts_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(accounts)
final accountsProvider = AccountsProvider._();

final class AccountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Account>>,
          List<Account>,
          Stream<List<Account>>
        >
    with $FutureModifier<List<Account>>, $StreamProvider<List<Account>> {
  AccountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountsHash();

  @$internal
  @override
  $StreamProviderElement<List<Account>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Account>> create(Ref ref) {
    return accounts(ref);
  }
}

String _$accountsHash() => r'67a7bc9389ef69b99d5e5df213c16f87304d0c34';

/// UID of the selected account, persisted across restarts.

@ProviderFor(ActiveUid)
final activeUidProvider = ActiveUidProvider._();

/// UID of the selected account, persisted across restarts.
final class ActiveUidProvider
    extends $AsyncNotifierProvider<ActiveUid, String?> {
  /// UID of the selected account, persisted across restarts.
  ActiveUidProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeUidProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeUidHash();

  @$internal
  @override
  ActiveUid create() => ActiveUid();
}

String _$activeUidHash() => r'dde518a11ef37254f8482e442723963337136829';

/// UID of the selected account, persisted across restarts.

abstract class _$ActiveUid extends $AsyncNotifier<String?> {
  FutureOr<String?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, String?>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The selected account, falling back to the first one when the stored UID is
/// gone or unset. Null while loading or when there are no accounts.

@ProviderFor(activeAccount)
final activeAccountProvider = ActiveAccountProvider._();

/// The selected account, falling back to the first one when the stored UID is
/// gone or unset. Null while loading or when there are no accounts.

final class ActiveAccountProvider
    extends $FunctionalProvider<Account?, Account?, Account?>
    with $Provider<Account?> {
  /// The selected account, falling back to the first one when the stored UID is
  /// gone or unset. Null while loading or when there are no accounts.
  ActiveAccountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeAccountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeAccountHash();

  @$internal
  @override
  $ProviderElement<Account?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Account? create(Ref ref) {
    return activeAccount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Account? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Account?>(value),
    );
  }
}

String _$activeAccountHash() => r'3d7cf8daf5df545bbff617dd84e0303bc420dd64';

/// Whether UIDs are shown as their first three digits only. On by default, so
/// screenshots of the app don't expose the account.

@ProviderFor(MaskUid)
final maskUidProvider = MaskUidProvider._();

/// Whether UIDs are shown as their first three digits only. On by default, so
/// screenshots of the app don't expose the account.
final class MaskUidProvider extends $NotifierProvider<MaskUid, bool> {
  /// Whether UIDs are shown as their first three digits only. On by default, so
  /// screenshots of the app don't expose the account.
  MaskUidProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'maskUidProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$maskUidHash();

  @$internal
  @override
  MaskUid create() => MaskUid();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$maskUidHash() => r'c5bea96170b6f229eda58e56992c51e62dac5aad';

/// Whether UIDs are shown as their first three digits only. On by default, so
/// screenshots of the app don't expose the account.

abstract class _$MaskUid extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
