// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_import_urls.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(savedImportUrls)
final savedImportUrlsProvider = SavedImportUrlsProvider._();

final class SavedImportUrlsProvider
    extends
        $FunctionalProvider<SavedImportUrls, SavedImportUrls, SavedImportUrls>
    with $Provider<SavedImportUrls> {
  SavedImportUrlsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedImportUrlsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedImportUrlsHash();

  @$internal
  @override
  $ProviderElement<SavedImportUrls> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SavedImportUrls create(Ref ref) {
    return savedImportUrls(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SavedImportUrls value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SavedImportUrls>(value),
    );
  }
}

String _$savedImportUrlsHash() => r'9d0deb9da6d67f251c185d955354c873cb4ec519';
