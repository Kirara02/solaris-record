// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(records)
final recordsProvider = RecordsFamily._();

final class RecordsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ConveneRecord>>,
          List<ConveneRecord>,
          Stream<List<ConveneRecord>>
        >
    with
        $FutureModifier<List<ConveneRecord>>,
        $StreamProvider<List<ConveneRecord>> {
  RecordsProvider._({
    required RecordsFamily super.from,
    required (String, PoolType) super.argument,
  }) : super(
         retry: null,
         name: r'recordsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recordsHash();

  @override
  String toString() {
    return r'recordsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<ConveneRecord>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ConveneRecord>> create(Ref ref) {
    final argument = this.argument as (String, PoolType);
    return records(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is RecordsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recordsHash() => r'915043f09c6cd50a97b55820b8ecdeadf9ea1ca7';

final class RecordsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<ConveneRecord>>,
          (String, PoolType)
        > {
  RecordsFamily._()
    : super(
        retry: null,
        name: r'recordsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RecordsProvider call(String uid, PoolType pool) =>
      RecordsProvider._(argument: (uid, pool), from: this);

  @override
  String toString() => r'recordsProvider';
}

@ProviderFor(poolStats)
final poolStatsProvider = PoolStatsFamily._();

final class PoolStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<PoolStats>,
          AsyncValue<PoolStats>,
          AsyncValue<PoolStats>
        >
    with $Provider<AsyncValue<PoolStats>> {
  PoolStatsProvider._({
    required PoolStatsFamily super.from,
    required (String, PoolType) super.argument,
  }) : super(
         retry: null,
         name: r'poolStatsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$poolStatsHash();

  @override
  String toString() {
    return r'poolStatsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<PoolStats>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<PoolStats> create(Ref ref) {
    final argument = this.argument as (String, PoolType);
    return poolStats(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<PoolStats> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<PoolStats>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PoolStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$poolStatsHash() => r'f8c3c67be7a36f86cacaf851754abd7769c9ff26';

final class PoolStatsFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<PoolStats>, (String, PoolType)> {
  PoolStatsFamily._()
    : super(
        retry: null,
        name: r'poolStatsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PoolStatsProvider call(String uid, PoolType pool) =>
      PoolStatsProvider._(argument: (uid, pool), from: this);

  @override
  String toString() => r'poolStatsProvider';
}

/// Statistics over every pull type of [uid]; loading until all pools arrived.

@ProviderFor(overviewStats)
final overviewStatsProvider = OverviewStatsFamily._();

/// Statistics over every pull type of [uid]; loading until all pools arrived.

final class OverviewStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<OverviewStats>,
          AsyncValue<OverviewStats>,
          AsyncValue<OverviewStats>
        >
    with $Provider<AsyncValue<OverviewStats>> {
  /// Statistics over every pull type of [uid]; loading until all pools arrived.
  OverviewStatsProvider._({
    required OverviewStatsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'overviewStatsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$overviewStatsHash();

  @override
  String toString() {
    return r'overviewStatsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<OverviewStats>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<OverviewStats> create(Ref ref) {
    final argument = this.argument as String;
    return overviewStats(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<OverviewStats> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<OverviewStats>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OverviewStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$overviewStatsHash() => r'c4fac1fb4a3d4dc37c734c57da3f261789dd597b';

/// Statistics over every pull type of [uid]; loading until all pools arrived.

final class OverviewStatsFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<OverviewStats>, String> {
  OverviewStatsFamily._()
    : super(
        retry: null,
        name: r'overviewStatsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Statistics over every pull type of [uid]; loading until all pools arrived.

  OverviewStatsProvider call(String uid) =>
      OverviewStatsProvider._(argument: uid, from: this);

  @override
  String toString() => r'overviewStatsProvider';
}
