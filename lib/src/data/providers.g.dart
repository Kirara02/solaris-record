// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'59cce38d45eeaba199eddd097d8e149d66f9f3e1';

@ProviderFor(conveneRepository)
final conveneRepositoryProvider = ConveneRepositoryProvider._();

final class ConveneRepositoryProvider
    extends
        $FunctionalProvider<
          ConveneRepository,
          ConveneRepository,
          ConveneRepository
        >
    with $Provider<ConveneRepository> {
  ConveneRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conveneRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conveneRepositoryHash();

  @$internal
  @override
  $ProviderElement<ConveneRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConveneRepository create(Ref ref) {
    return conveneRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConveneRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConveneRepository>(value),
    );
  }
}

String _$conveneRepositoryHash() => r'bf0ed7ca05a9e268841b35d67dc2f6b152088dd1';

@ProviderFor(conveneApi)
final conveneApiProvider = ConveneApiProvider._();

final class ConveneApiProvider
    extends $FunctionalProvider<ConveneApi, ConveneApi, ConveneApi>
    with $Provider<ConveneApi> {
  ConveneApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conveneApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conveneApiHash();

  @$internal
  @override
  $ProviderElement<ConveneApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ConveneApi create(Ref ref) {
    return conveneApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConveneApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConveneApi>(value),
    );
  }
}

String _$conveneApiHash() => r'04dd4ce42523c576da2e56adb7db9e8847254c48';

@ProviderFor(itemImageService)
final itemImageServiceProvider = ItemImageServiceProvider._();

final class ItemImageServiceProvider
    extends
        $FunctionalProvider<
          ItemImageService,
          ItemImageService,
          ItemImageService
        >
    with $Provider<ItemImageService> {
  ItemImageServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'itemImageServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$itemImageServiceHash();

  @$internal
  @override
  $ProviderElement<ItemImageService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ItemImageService create(Ref ref) {
    return itemImageService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ItemImageService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ItemImageService>(value),
    );
  }
}

String _$itemImageServiceHash() => r'836a31652343ee7abd5a36a1331c2582ec767c0c';

@ProviderFor(itemNameService)
final itemNameServiceProvider = ItemNameServiceProvider._();

final class ItemNameServiceProvider
    extends
        $FunctionalProvider<ItemNameService, ItemNameService, ItemNameService>
    with $Provider<ItemNameService> {
  ItemNameServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'itemNameServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$itemNameServiceHash();

  @$internal
  @override
  $ProviderElement<ItemNameService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ItemNameService create(Ref ref) {
    return itemNameService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ItemNameService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ItemNameService>(value),
    );
  }
}

String _$itemNameServiceHash() => r'1d57bb597da2dc5714f483b597cd0ffdbe3d02d6';

/// Icon URL for an item, or null when none is available. Cached per item for
/// the app's lifetime.

@ProviderFor(itemImageUrl)
final itemImageUrlProvider = ItemImageUrlFamily._();

/// Icon URL for an item, or null when none is available. Cached per item for
/// the app's lifetime.

final class ItemImageUrlProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// Icon URL for an item, or null when none is available. Cached per item for
  /// the app's lifetime.
  ItemImageUrlProvider._({
    required ItemImageUrlFamily super.from,
    required (int, String) super.argument,
  }) : super(
         retry: null,
         name: r'itemImageUrlProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$itemImageUrlHash();

  @override
  String toString() {
    return r'itemImageUrlProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as (int, String);
    return itemImageUrl(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ItemImageUrlProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$itemImageUrlHash() => r'8306158a96fe372c6e04b28a05b08911a4825245';

/// Icon URL for an item, or null when none is available. Cached per item for
/// the app's lifetime.

final class ItemImageUrlFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, (int, String)> {
  ItemImageUrlFamily._()
    : super(
        retry: null,
        name: r'itemImageUrlProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Icon URL for an item, or null when none is available. Cached per item for
  /// the app's lifetime.

  ItemImageUrlProvider call(int resourceId, String resourceType) =>
      ItemImageUrlProvider._(argument: (resourceId, resourceType), from: this);

  @override
  String toString() => r'itemImageUrlProvider';
}

/// Disk usage for the Data & storage screen. Invalidate after clearing data.

@ProviderFor(storageUsage)
final storageUsageProvider = StorageUsageProvider._();

/// Disk usage for the Data & storage screen. Invalidate after clearing data.

final class StorageUsageProvider
    extends
        $FunctionalProvider<
          AsyncValue<StorageUsage>,
          StorageUsage,
          FutureOr<StorageUsage>
        >
    with $FutureModifier<StorageUsage>, $FutureProvider<StorageUsage> {
  /// Disk usage for the Data & storage screen. Invalidate after clearing data.
  StorageUsageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storageUsageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storageUsageHash();

  @$internal
  @override
  $FutureProviderElement<StorageUsage> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<StorageUsage> create(Ref ref) {
    return storageUsage(ref);
  }
}

String _$storageUsageHash() => r'2767dd67e68159d643b2d6a45ccc6859dfab45f4';

@ProviderFor(encoreInfoService)
final encoreInfoServiceProvider = EncoreInfoServiceProvider._();

final class EncoreInfoServiceProvider
    extends
        $FunctionalProvider<
          EncoreInfoService,
          EncoreInfoService,
          EncoreInfoService
        >
    with $Provider<EncoreInfoService> {
  EncoreInfoServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'encoreInfoServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$encoreInfoServiceHash();

  @$internal
  @override
  $ProviderElement<EncoreInfoService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EncoreInfoService create(Ref ref) {
    return encoreInfoService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EncoreInfoService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EncoreInfoService>(value),
    );
  }
}

String _$encoreInfoServiceHash() => r'4370c404614eec67619eb0a17d496e64b6dc3e52';

/// Reference info for an item in [lang]. Kept alive so reopening is instant.

@ProviderFor(itemInfo)
final itemInfoProvider = ItemInfoFamily._();

/// Reference info for an item in [lang]. Kept alive so reopening is instant.

final class ItemInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<ItemInfo?>,
          ItemInfo?,
          FutureOr<ItemInfo?>
        >
    with $FutureModifier<ItemInfo?>, $FutureProvider<ItemInfo?> {
  /// Reference info for an item in [lang]. Kept alive so reopening is instant.
  ItemInfoProvider._({
    required ItemInfoFamily super.from,
    required (int, String, String) super.argument,
  }) : super(
         retry: _noRetry,
         name: r'itemInfoProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$itemInfoHash();

  @override
  String toString() {
    return r'itemInfoProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<ItemInfo?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ItemInfo?> create(Ref ref) {
    final argument = this.argument as (int, String, String);
    return itemInfo(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is ItemInfoProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$itemInfoHash() => r'ff17bbbb216017a8379433189a9784083095dae7';

/// Reference info for an item in [lang]. Kept alive so reopening is instant.

final class ItemInfoFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ItemInfo?>, (int, String, String)> {
  ItemInfoFamily._()
    : super(
        retry: _noRetry,
        name: r'itemInfoProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Reference info for an item in [lang]. Kept alive so reopening is instant.

  ItemInfoProvider call(int resourceId, String resourceType, String lang) =>
      ItemInfoProvider._(
        argument: (resourceId, resourceType, lang),
        from: this,
      );

  @override
  String toString() => r'itemInfoProvider';
}

@ProviderFor(urlOpener)
final urlOpenerProvider = UrlOpenerProvider._();

final class UrlOpenerProvider
    extends $FunctionalProvider<UrlOpener, UrlOpener, UrlOpener>
    with $Provider<UrlOpener> {
  UrlOpenerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'urlOpenerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$urlOpenerHash();

  @$internal
  @override
  $ProviderElement<UrlOpener> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UrlOpener create(Ref ref) {
    return urlOpener(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UrlOpener value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UrlOpener>(value),
    );
  }
}

String _$urlOpenerHash() => r'ec75d4bf72ba8df9d024bc888607ecc175bdb437';
