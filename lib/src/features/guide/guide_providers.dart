import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'data/guide_service.dart';
import 'domain/guide_entry.dart';

part 'guide_providers.g.dart';

@Riverpod(keepAlive: true)
GuideService guideService(Ref ref) => GuideService();

/// The guide screens offer their own retry button, so don't retry silently.
Duration? _noRetry(int retryCount, Object error) => null;

/// Every entry of [kind] in [lang]. Kept alive so switching tabs is instant.
@Riverpod(keepAlive: true, retry: _noRetry)
Future<List<GuideEntry>> guideEntries(
  Ref ref,
  GuideKind kind,
  String lang,
) async {
  try {
    return await ref.watch(guideServiceProvider).list(kind, lang);
  } on Object catch (e, st) {
    Logger('guide')
        .warning('Guide list failed kind=${kind.name} lang=$lang', e, st);
    rethrow;
  }
}

/// Details of one echo in [lang].
@Riverpod(keepAlive: true, retry: _noRetry)
Future<EchoInfo?> echoInfo(Ref ref, int id, String lang) async {
  try {
    return await ref.watch(guideServiceProvider).echo(id, lang);
  } on Object catch (e, st) {
    Logger('guide').warning('Echo info failed id=$id lang=$lang', e, st);
    rethrow;
  }
}
