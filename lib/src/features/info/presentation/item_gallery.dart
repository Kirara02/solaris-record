import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:logging/logging.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/theme/app_tokens.dart';
import '../../../shared/theme/mornye_icons.dart';
import '../../../shared/widgets/settings_group.dart';
import '../domain/item_info.dart';

final _log = Logger('gallery');

String _kindLabel(Translations t, ItemGalleryKind kind) => switch (kind) {
  ItemGalleryKind.icon => t.info.galleryIcon,
  ItemGalleryKind.outfit => t.info.galleryOutfit,
  ItemGalleryKind.convene => t.info.galleryConvene,
  ItemGalleryKind.skill => t.info.gallerySkill,
};

/// Large image of an item with chips for its image groups (icon, outfit,
/// convene art) and arrows through the images of a group. Tapping the image
/// opens it in a zoomable viewer.
class ItemGalleryCard extends StatefulWidget {
  const ItemGalleryCard({
    super.key,
    required this.groups,
    required this.accent,
    this.shiftLeft = false,
  });

  final List<ItemGallery> groups;
  final Color accent;

  /// Nudges the art left (weapon art sits right of center).
  final bool shiftLeft;

  @override
  State<ItemGalleryCard> createState() => _ItemGalleryCardState();
}

class _ItemGalleryCardState extends State<ItemGalleryCard> {
  int _group = 0;
  int _index = 0;

  ItemGallery get _current => widget.groups[_group];

  void _step(int delta) {
    final n = _current.urls.length;
    setState(() => _index = (_index + delta) % n);
  }

  // Scaling up first keeps the bleed on the right edge from showing a gap.
  Widget _shifted(Widget image) => widget.shiftLeft
      ? FractionalTranslation(
          translation: const Offset(-0.1, 0),
          child: Transform.scale(scale: 1.2, child: image),
        )
      : image;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final scheme = Theme.of(context).colorScheme;
    final urls = _current.urls;
    final url = urls[_index.clamp(0, urls.length - 1)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 240,
          decoration: BoxDecoration(
            color: widget.accent.withValues(alpha: 0.10),
            borderRadius: context.tokens.borderRadiusCard,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              InkWell(
                onTap: () => showImageViewer(context, url),
                child: _shifted(
                  CachedNetworkImage(
                    key: ValueKey(url),
                    imageUrl: url,
                    fit: BoxFit.contain,
                    placeholder: (_, _) =>
                        const Center(child: M3ELoadingIndicator()),
                    errorWidget: (_, _, _) => Center(
                      child: AdaptiveIcon(
                        Icons.image_not_supported_outlined,
                        color: widget.accent,
                      ),
                    ),
                  ),
                ),
              ),
              if (_current.captionAt(_index) case final caption?)
                Positioned(
                  left: 12,
                  bottom: 8,
                  right: 80,
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: scheme.surface.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        child: Text(
                          caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ),
                  ),
                ),
              if (urls.length > 1) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    tooltip: t.info.galleryPrevious,
                    icon: const AdaptiveIcon(Icons.chevron_left),
                    onPressed: () => _step(-1),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    tooltip: t.info.galleryNext,
                    icon: const AdaptiveIcon(Icons.chevron_right),
                    onPressed: () => _step(1),
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: 8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.surface.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      child: Text(
                        '${_index + 1} / ${urls.length}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (widget.groups.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (i, g) in widget.groups.indexed)
                  SettingsChoiceChip(
                    label: _kindLabel(t, g.kind),
                    isSelected: i == _group,
                    onTap: () => setState(() {
                      _group = i;
                      _index = 0;
                    }),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Full-screen viewer for [url]: pinch or wheel to zoom, buttons to zoom,
/// save the image to a file, or re-download it if the cached copy is broken.
Future<void> showImageViewer(BuildContext context, String url) =>
    showDialog<void>(
      context: context,
      builder: (context) => _ImageViewer(url: url),
    );

class _ImageViewer extends StatefulWidget {
  const _ImageViewer({required this.url});

  final String url;

  @override
  State<_ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<_ImageViewer> {
  final _transform = TransformationController();
  int _nonce = 0;

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  void _zoom(double factor) {
    final scale = (_transform.value.getMaxScaleOnAxis() * factor).clamp(
      1.0,
      6.0,
    );
    _transform.value = Matrix4.identity()..scaleByDouble(scale, scale, 1, 1);
  }

  Future<void> _save() async {
    final t = context.t;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final file = await DefaultCacheManager().getSingleFile(widget.url);
      final bytes = await file.readAsBytes();
      final name = widget.url.split('?').first.split('/').last;
      final saved = await FilePicker.saveFile(
        fileName: name,
        bytes: Uint8List.fromList(bytes),
        mimeType: 'image/webp',
        type: FileType.custom,
        allowedExtensions: const ['webp'],
      );
      if (saved == null) return;
      _log.info('Image saved name=$name bytes=${bytes.length}');
      messenger.showSnackBar(SnackBar(content: Text(t.info.imageSaved)));
    } on Object catch (e, st) {
      _log.warning('Image save failed', e, st);
      messenger.showSnackBar(SnackBar(content: Text(t.info.imageSaveFailed)));
    }
  }

  Future<void> _refetch() async {
    await DefaultCacheManager().removeFile(widget.url);
    await CachedNetworkImage.evictFromCache(widget.url);
    _log.info('Image cache dropped for re-fetch');
    if (mounted) setState(() => _nonce++);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final scheme = Theme.of(context).colorScheme;
    return Dialog.fullscreen(
      backgroundColor: scheme.surface,
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _transform,
              minScale: 1,
              maxScale: 6,
              child: CachedNetworkImage(
                key: ValueKey('${widget.url}#$_nonce'),
                imageUrl: widget.url,
                fit: BoxFit.contain,
                placeholder: (_, _) =>
                    const Center(child: M3ELoadingIndicator()),
                errorWidget: (_, _, _) => Center(
                  child: Text(
                    t.info.imageLoadFailed,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHigh.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: t.info.imageZoomOut,
                        icon: const AdaptiveIcon(Icons.zoom_out),
                        onPressed: () => _zoom(1 / 1.5),
                      ),
                      IconButton(
                        tooltip: t.info.imageZoomIn,
                        icon: const AdaptiveIcon(Icons.zoom_in),
                        onPressed: () => _zoom(1.5),
                      ),
                      IconButton(
                        tooltip: t.info.imageSave,
                        icon: const AdaptiveIcon(Icons.download_outlined),
                        onPressed: _save,
                      ),
                      IconButton(
                        tooltip: t.info.imageRefetch,
                        icon: const AdaptiveIcon(Icons.refresh),
                        onPressed: _refetch,
                      ),
                      IconButton(
                        tooltip: t.info.close,
                        icon: const AdaptiveIcon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
