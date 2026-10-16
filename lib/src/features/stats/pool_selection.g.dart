// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pool_selection.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What the Convene screen shows: one pull type, or `null` for the global
/// overview. Shared so the wide layout's navigation rail, the phone's
/// Overview / Convene tabs and the screen's own selector stay in sync.

@ProviderFor(SelectedPool)
final selectedPoolProvider = SelectedPoolProvider._();

/// What the Convene screen shows: one pull type, or `null` for the global
/// overview. Shared so the wide layout's navigation rail, the phone's
/// Overview / Convene tabs and the screen's own selector stay in sync.
final class SelectedPoolProvider
    extends $NotifierProvider<SelectedPool, PoolType?> {
  /// What the Convene screen shows: one pull type, or `null` for the global
  /// overview. Shared so the wide layout's navigation rail, the phone's
  /// Overview / Convene tabs and the screen's own selector stay in sync.
  SelectedPoolProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedPoolProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedPoolHash();

  @$internal
  @override
  SelectedPool create() => SelectedPool();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PoolType? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PoolType?>(value),
    );
  }
}

String _$selectedPoolHash() => r'35efa54426d50e0d8af98c1494acc552f2eae5e5';

/// What the Convene screen shows: one pull type, or `null` for the global
/// overview. Shared so the wide layout's navigation rail, the phone's
/// Overview / Convene tabs and the screen's own selector stay in sync.

abstract class _$SelectedPool extends $Notifier<PoolType?> {
  PoolType? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PoolType?, PoolType?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PoolType?, PoolType?>,
              PoolType?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
