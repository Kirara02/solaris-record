// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ThemeSettingsController)
final themeSettingsControllerProvider = ThemeSettingsControllerProvider._();

final class ThemeSettingsControllerProvider
    extends $NotifierProvider<ThemeSettingsController, ThemeSettings> {
  ThemeSettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeSettingsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeSettingsControllerHash();

  @$internal
  @override
  ThemeSettingsController create() => ThemeSettingsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeSettings>(value),
    );
  }
}

String _$themeSettingsControllerHash() =>
    r'8928e26a9659479604ddf975b27a614994c1d336';

abstract class _$ThemeSettingsController extends $Notifier<ThemeSettings> {
  ThemeSettings build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ThemeSettings, ThemeSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeSettings, ThemeSettings>,
              ThemeSettings,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Language override: `null` follows the device, otherwise a slang locale code
/// (`en`, `id`).

@ProviderFor(AppLanguage)
final appLanguageProvider = AppLanguageProvider._();

/// Language override: `null` follows the device, otherwise a slang locale code
/// (`en`, `id`).
final class AppLanguageProvider
    extends $NotifierProvider<AppLanguage, String?> {
  /// Language override: `null` follows the device, otherwise a slang locale code
  /// (`en`, `id`).
  AppLanguageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLanguageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLanguageHash();

  @$internal
  @override
  AppLanguage create() => AppLanguage();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$appLanguageHash() => r'be74ed0f0df3824157917967f252329f21524141';

/// Language override: `null` follows the device, otherwise a slang locale code
/// (`en`, `id`).

abstract class _$AppLanguage extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Language of item names in pull records and charts, independent of the app
/// language. `null` shows the English names as stored; otherwise an encore.moe
/// language code. Stored records are never changed by this.

@ProviderFor(DataLanguage)
final dataLanguageProvider = DataLanguageProvider._();

/// Language of item names in pull records and charts, independent of the app
/// language. `null` shows the English names as stored; otherwise an encore.moe
/// language code. Stored records are never changed by this.
final class DataLanguageProvider
    extends $NotifierProvider<DataLanguage, String?> {
  /// Language of item names in pull records and charts, independent of the app
  /// language. `null` shows the English names as stored; otherwise an encore.moe
  /// language code. Stored records are never changed by this.
  DataLanguageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dataLanguageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dataLanguageHash();

  @$internal
  @override
  DataLanguage create() => DataLanguage();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$dataLanguageHash() => r'ba30b5104886b6638497b1e3e7caa026f3e731a5';

/// Language of item names in pull records and charts, independent of the app
/// language. `null` shows the English names as stored; otherwise an encore.moe
/// language code. Stored records are never changed by this.

abstract class _$DataLanguage extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Size of the stored debug logs in bytes. Invalidate after clearing them.

@ProviderFor(logSize)
final logSizeProvider = LogSizeProvider._();

/// Size of the stored debug logs in bytes. Invalidate after clearing them.

final class LogSizeProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Size of the stored debug logs in bytes. Invalidate after clearing them.
  LogSizeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'logSizeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$logSizeHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return logSize(ref);
  }
}

String _$logSizeHash() => r'6176fcba8fadca9d6b1cb729a6ba1dc32189c2dd';
