// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_names.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Names by id in the selected data language. Empty while loading, when no
/// data language is set, or when the catalog can't be loaded, so the UI simply
/// keeps the stored English names.

@ProviderFor(itemNames)
final itemNamesProvider = ItemNamesProvider._();

/// Names by id in the selected data language. Empty while loading, when no
/// data language is set, or when the catalog can't be loaded, so the UI simply
/// keeps the stored English names.

final class ItemNamesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<int, String>>,
          Map<int, String>,
          FutureOr<Map<int, String>>
        >
    with $FutureModifier<Map<int, String>>, $FutureProvider<Map<int, String>> {
  /// Names by id in the selected data language. Empty while loading, when no
  /// data language is set, or when the catalog can't be loaded, so the UI simply
  /// keeps the stored English names.
  ItemNamesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'itemNamesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$itemNamesHash();

  @$internal
  @override
  $FutureProviderElement<Map<int, String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<int, String>> create(Ref ref) {
    return itemNames(ref);
  }
}

String _$itemNamesHash() => r'7473f9cc217a7c3c1c333680ba2a20afd9f33c39';

@ProviderFor(itemNameResolver)
final itemNameResolverProvider = ItemNameResolverProvider._();

final class ItemNameResolverProvider
    extends
        $FunctionalProvider<
          ItemNameResolver,
          ItemNameResolver,
          ItemNameResolver
        >
    with $Provider<ItemNameResolver> {
  ItemNameResolverProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'itemNameResolverProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$itemNameResolverHash();

  @$internal
  @override
  $ProviderElement<ItemNameResolver> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ItemNameResolver create(Ref ref) {
    return itemNameResolver(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ItemNameResolver value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ItemNameResolver>(value),
    );
  }
}

String _$itemNameResolverHash() => r'288eaea8a27f5adad91288fd5a8183224221111b';
