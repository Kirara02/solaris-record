import 'dart:async';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers.dart';

part 'artwork_palette.g.dart';

final _log = Logger('theme');

/// Side of the thumbnail the colours are sampled from; enough for a dominant
/// colour and cheap to quantize on the UI thread.
const _sampleSize = 64;

/// A colour scheme seeded from the dominant colour of the image at [url], or
/// null when the image can't be read. The icon is cached on disk already, so
/// this only decodes it small and quantizes it.
@riverpod
Future<ColorScheme?> artworkPalette(
  Ref ref,
  String url,
  Brightness brightness,
) async {
  try {
    final image = await _decode(url);
    final data = await image.toByteData();
    image.dispose();
    if (data == null) return null;

    final pixels = <int>[];
    for (var i = 0; i + 3 < data.lengthInBytes; i += 4) {
      final a = data.getUint8(i + 3);
      if (a < 128) continue;
      pixels.add(
        0xFF000000 |
            data.getUint8(i) << 16 |
            data.getUint8(i + 1) << 8 |
            data.getUint8(i + 2),
      );
    }
    if (pixels.isEmpty) return null;

    final quantized = await QuantizerCelebi().quantize(pixels, 128);
    final seed = Score.score(quantized.colorToCount, desired: 1).first;
    return ColorScheme.fromSeed(seedColor: Color(seed), brightness: brightness);
  } on Object catch (e) {
    _log.fine('Could not derive a palette: $e');
    return null;
  }
}

Future<ui.Image> _decode(String url) {
  final completer = Completer<ui.Image>();
  final stream = ResizeImage(
    CachedNetworkImageProvider(url),
    width: _sampleSize,
  ).resolve(ImageConfiguration.empty);
  late final ImageStreamListener listener;
  listener = ImageStreamListener(
    (info, _) {
      if (!completer.isCompleted) completer.complete(info.image.clone());
      stream.removeListener(listener);
    },
    onError: (error, stack) {
      if (!completer.isCompleted) completer.completeError(error, stack);
      stream.removeListener(listener);
    },
  );
  stream.addListener(listener);
  return completer.future;
}

/// Tints the accent colours of [child] with the dominant colour of an item's
/// icon. Surfaces and neutrals stay the app's own, so AMOLED and the dynamic
/// palette keep working; until the colour is ready nothing changes.
class ArtworkAccent extends ConsumerWidget {
  const ArtworkAccent({
    super.key,
    required this.resourceId,
    required this.resourceType,
    required this.child,
  });

  final int resourceId;
  final String resourceType;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = resourceId > 0
        ? ref.watch(itemImageUrlProvider(resourceId, resourceType)).value
        : null;
    if (url == null) return child;
    final art = ref
        .watch(artworkPaletteProvider(url, Theme.of(context).brightness))
        .value;
    if (art == null) return child;

    final data = M3ETheme.of(context);
    return M3ETheme(
      data: data.copyWith(
        colorScheme: data.colorScheme
            .copyWith(
              primary: art.primary,
              onPrimary: art.onPrimary,
              primaryContainer: art.primaryContainer,
              onPrimaryContainer: art.onPrimaryContainer,
              secondary: art.secondary,
              onSecondary: art.onSecondary,
              secondaryContainer: art.secondaryContainer,
              onSecondaryContainer: art.onSecondaryContainer,
              tertiary: art.tertiary,
              onTertiary: art.onTertiary,
              tertiaryContainer: art.tertiaryContainer,
              onTertiaryContainer: art.onTertiaryContainer,
              inversePrimary: art.inversePrimary,
              surfaceTint: art.surfaceTint,
            )
            .harmonized(),
      ),
      child: child,
    );
  }
}
