// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rail_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the "Pull types" group in the rail is open (it can be collapsed).

@ProviderFor(PoolGroupExpanded)
final poolGroupExpandedProvider = PoolGroupExpandedProvider._();

/// Whether the "Pull types" group in the rail is open (it can be collapsed).
final class PoolGroupExpandedProvider
    extends $NotifierProvider<PoolGroupExpanded, bool> {
  /// Whether the "Pull types" group in the rail is open (it can be collapsed).
  PoolGroupExpandedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'poolGroupExpandedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$poolGroupExpandedHash();

  @$internal
  @override
  PoolGroupExpanded create() => PoolGroupExpanded();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$poolGroupExpandedHash() => r'5c2d2e95284f1ad471a4177648c2ce37c003521d';

/// Whether the "Pull types" group in the rail is open (it can be collapsed).

abstract class _$PoolGroupExpanded extends $Notifier<bool> {
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

/// App version for the rail's brand header ("1.0.0"), or null when it can't be
/// read (e.g. in tests, where the platform plugin is missing).

@ProviderFor(appVersion)
final appVersionProvider = AppVersionProvider._();

/// App version for the rail's brand header ("1.0.0"), or null when it can't be
/// read (e.g. in tests, where the platform plugin is missing).

final class AppVersionProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// App version for the rail's brand header ("1.0.0"), or null when it can't be
  /// read (e.g. in tests, where the platform plugin is missing).
  AppVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appVersionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appVersionHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return appVersion(ref);
  }
}

String _$appVersionHash() => r'2818345568e93ac92311e6bcf0a9d9ec018d5020';
