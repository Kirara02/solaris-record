import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:material_ui/material_ui.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'domain/convene_url.dart';
import 'presentation/import_dialog.dart';

part 'share_intent.g.dart';

final _log = Logger('share');

/// A convene URL another app shared to this one, until the import dialog has
/// taken it.
@Riverpod(keepAlive: true)
class SharedConveneUrl extends _$SharedConveneUrl {
  @override
  String? build() => null;

  void offer(String? url) => state = url;
}

/// Opens the import dialog, filled in, when a convene URL is shared to the app
/// (Android's share sheet, "Share" on a copied link). Does nothing elsewhere:
/// iOS would need a share extension.
class ShareIntentListener extends ConsumerStatefulWidget {
  const ShareIntentListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ShareIntentListener> createState() =>
      _ShareIntentListenerState();
}

class _ShareIntentListenerState extends ConsumerState<ShareIntentListener> {
  StreamSubscription<List<SharedMediaFile>>? _subscription;

  bool get _supported =>
      !kIsWeb &&
      Platform.isAndroid &&
      !Platform.environment.containsKey('FLUTTER_TEST');

  @override
  void initState() {
    super.initState();
    if (!_supported) return;
    final intent = ReceiveSharingIntent.instance;
    _subscription = intent.getMediaStream().listen(
      _handle,
      onError: (Object e) => _log.warning('Share stream failed: $e'),
    );
    intent.getInitialMedia().then((files) {
      if (files.isEmpty) return;
      _handle(files);
      intent.reset();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _handle(List<SharedMediaFile> files) {
    for (final file in files) {
      if (file.type != SharedMediaType.text &&
          file.type != SharedMediaType.url) {
        continue;
      }
      final url = extractConveneUrl(file.path);
      if (url != null) {
        _log.info('Received a convene link from another app');
        if (mounted) ref.read(sharedConveneUrlProvider.notifier).offer(url);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sharedConveneUrlProvider, (_, url) {
      if (url == null) return;
      ref.read(sharedConveneUrlProvider.notifier).offer(null);
      showImportDialog(context, initialUrl: url);
    });
    return widget.child;
  }
}
