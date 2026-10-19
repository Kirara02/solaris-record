import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../theme/mornye_icons.dart';

/// Rarity-tinted tile showing an item's icon, with a star placeholder while
/// loading or when no icon exists. Disk-cached by CachedNetworkImage.
class ItemIcon extends ConsumerWidget {
  const ItemIcon({
    super.key,
    required this.resourceId,
    required this.resourceType,
    required this.rarity,
    this.size = 44,
    this.circular = false,
    this.ringColor,
  });

  final int resourceId;
  final String resourceType;
  final int rarity;
  final double size;

  /// Round avatar instead of a rounded square.
  final bool circular;

  /// Overrides the rarity-coloured border (used to mark 50/50 results).
  final Color? ringColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final color = rarityColor(scheme, rarity);
    final radius = BorderRadius.circular(context.tokens.radiusCover);
    final url = resourceId > 0
        ? ref.watch(itemImageUrlProvider(resourceId, resourceType)).value
        : null;

    Widget placeholder() => Center(
      child: AdaptiveIcon(Icons.star, size: size * 0.45, color: color),
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circular ? null : radius,
        border: Border.all(
          color: ringColor ?? color.withValues(alpha: rarity >= 4 ? 0.7 : 0.3),
          width: ringColor != null ? 3 : (rarity >= 4 ? 1.5 : 1),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null
          ? placeholder()
          : CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              fadeInDuration: const Duration(milliseconds: 150),
              placeholder: (_, _) => placeholder(),
              errorWidget: (_, _, _) => placeholder(),
            ),
    );
  }
}
