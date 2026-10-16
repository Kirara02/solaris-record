import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers.dart';
import '../settings/settings_providers.dart';

part 'item_names.g.dart';

final _log = Logger('names');

/// Name to show for an item: the translated one when known, else [fallback]
/// (the English name stored with the pull).
typedef ItemNameResolver = String Function(int resourceId, String fallback);

/// Names by id in the selected data language. Empty while loading, when no
/// data language is set, or when the catalog can't be loaded, so the UI simply
/// keeps the stored English names.
@riverpod
Future<Map<int, String>> itemNames(Ref ref) async {
  final lang = ref.watch(dataLanguageProvider);
  if (lang == null) return const {};
  try {
    final names = await ref.watch(itemNameServiceProvider).namesFor(lang);
    _log.info('Name catalog loaded lang=$lang items=${names.length}');
    // Keep a loaded catalog; a failed load is retried the next time it's
    // needed.
    ref.keepAlive();
    return names;
  } on Object catch (e, st) {
    _log.warning('Name catalog failed lang=$lang', e, st);
    rethrow;
  }
}

@riverpod
ItemNameResolver itemNameResolver(Ref ref) {
  final names = ref.watch(itemNamesProvider).value;
  if (names == null || names.isEmpty) return (_, fallback) => fallback;
  return (id, fallback) => names[id] ?? fallback;
}
