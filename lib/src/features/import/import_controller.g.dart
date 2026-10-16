// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Pool currently being fetched, for progress display.

@ProviderFor(ImportProgress)
final importProgressProvider = ImportProgressProvider._();

/// Pool currently being fetched, for progress display.
final class ImportProgressProvider
    extends $NotifierProvider<ImportProgress, PoolType?> {
  /// Pool currently being fetched, for progress display.
  ImportProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'importProgressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$importProgressHash();

  @$internal
  @override
  ImportProgress create() => ImportProgress();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PoolType? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PoolType?>(value),
    );
  }
}

String _$importProgressHash() => r'11d42af24234e2af939a2eb11190caa42948b9dc';

/// Pool currently being fetched, for progress display.

abstract class _$ImportProgress extends $Notifier<PoolType?> {
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

/// Idle state is `AsyncData(null)`; errors are [ConveneUrlException] or
/// [ConveneApiException].

@ProviderFor(ImportController)
final importControllerProvider = ImportControllerProvider._();

/// Idle state is `AsyncData(null)`; errors are [ConveneUrlException] or
/// [ConveneApiException].
final class ImportControllerProvider
    extends $AsyncNotifierProvider<ImportController, ImportSummary?> {
  /// Idle state is `AsyncData(null)`; errors are [ConveneUrlException] or
  /// [ConveneApiException].
  ImportControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'importControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$importControllerHash();

  @$internal
  @override
  ImportController create() => ImportController();
}

String _$importControllerHash() => r'ab922f5e78957f97ed9ff852474769f1b71d5533';

/// Idle state is `AsyncData(null)`; errors are [ConveneUrlException] or
/// [ConveneApiException].

abstract class _$ImportController extends $AsyncNotifier<ImportSummary?> {
  FutureOr<ImportSummary?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ImportSummary?>, ImportSummary?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ImportSummary?>, ImportSummary?>,
              AsyncValue<ImportSummary?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
