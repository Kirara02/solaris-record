import 'dart:io';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/providers.dart';
import '../presentation/share_card.dart';

final _log = Logger('share');

/// Loads every icon of [content] into the image cache, so the capture doesn't
/// catch a placeholder. Icons that fail to load are skipped (they render as the
/// star placeholder, the same as on screen).
Future<void> preloadIcons(
  BuildContext context,
  WidgetRef ref,
  ShareContent content,
) async {
  await Future.wait([
    for (final icon in content.icons)
      () async {
        try {
          final url = await ref.read(
            itemImageUrlProvider(icon.resourceId, icon.resourceType).future,
          );
          if (url == null || !context.mounted) return;
          await precacheImage(CachedNetworkImageProvider(url), context);
        } on Object catch (e) {
          _log.fine('Icon ${icon.resourceId} not preloaded: $e');
        }
      }(),
  ]);
  // Let the fade-in of freshly decoded icons finish before painting.
  await Future<void>.delayed(const Duration(milliseconds: 250));
  await WidgetsBinding.instance.endOfFrame;
}

/// Renders the [RepaintBoundary] behind [boundaryKey] to PNG bytes.
Future<Uint8List> capturePng(
  GlobalKey boundaryKey, {
  double pixelRatio = 2,
}) async {
  final boundary =
      boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) throw StateError('Share card is not on screen');
  final image = await boundary.toImage(pixelRatio: pixelRatio);
  try {
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) throw StateError('PNG encoding failed');
    return data.buffer.asUint8List();
  } finally {
    image.dispose();
  }
}

enum ShareOutcome { done, cancelled }

/// Whether the platform has a system share sheet (otherwise the image is
/// saved to a file).
bool get hasShareSheet =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

/// Hands [png] to the user: the system share sheet on phones; on desktop a
/// save dialog that starts in the Downloads folder. [name] is the saved file's
/// name, when there is one.
Future<({ShareOutcome outcome, String? name})> deliverPng(
  Uint8List png,
  String fileName, {
  Rect? origin,
}) async {
  if (hasShareSheet) {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(png, flush: true);
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        sharePositionOrigin: origin,
      ),
    );
    _log.info('Shared image bytes=${png.length} status=${result.status.name}');
    return (
      outcome: result.status == ShareResultStatus.dismissed
          ? ShareOutcome.cancelled
          : ShareOutcome.done,
      name: null,
    );
  }
  final downloads = kIsWeb ? null : await getDownloadsDirectory();
  final saved = await FilePicker.saveFile(
    fileName: fileName,
    bytes: png,
    initialDirectory: downloads?.path,
    mimeType: 'image/png',
  );
  if (saved == null) return (outcome: ShareOutcome.cancelled, name: null);
  _log.info('Saved image bytes=${png.length}');
  return (outcome: ShareOutcome.done, name: saved.pathSegments.last);
}
