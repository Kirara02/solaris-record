import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/providers.dart';
import '../../../shared/routing/app_routes.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_tokens.dart';
import '../../../shared/theme/mornye_icons.dart';
import '../../../shared/widgets/marquee_text.dart';
import '../../info/domain/item_info.dart';
import '../domain/guide_entry.dart';
import 'echo_labels.dart';

/// Portrait card of one guide entry: full-bleed art, the name over a dark
/// fade, element and weapon badges in the top right, and a rarity-coloured
/// edge along the bottom.
class GuideCard extends ConsumerWidget {
  const GuideCard({super.key, required this.entry});

  final GuideEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = entry.kind == GuideKind.echo
        ? echoClassColor(scheme, entry.rarity)
        : rarityColor(scheme, entry.rarity);
    final radius = BorderRadius.circular(context.tokens.radiusCard);
    final isResonator = entry.kind == GuideKind.resonator;

    // Resonators show their first outfit art once the detail has loaded (one
    // request per resonator, disk-cached; English is enough, only the image is
    // read), the head icon until then. Weapons and echoes are square icons
    // that sit on a rarity-tinted backdrop instead.
    final portrait = isResonator
        ? ref
              .watch(itemInfoProvider(entry.id, 'resonator', 'en'))
              .value
              ?.gallery
              .where((g) => g.kind == ItemGalleryKind.outfit)
              .firstOrNull
              ?.urls
              .firstOrNull
        : null;
    final url = portrait ?? entry.iconUrl;

    Widget art() {
      if (url == null) {
        return Center(child: AdaptiveIcon(Icons.star, color: color));
      }
      return CachedNetworkImage(
        imageUrl: url,
        fit: portrait != null ? BoxFit.cover : BoxFit.contain,
        alignment: Alignment.topCenter,
        memCacheWidth: 400,
        fadeInDuration: const Duration(milliseconds: 150),
        placeholder: (_, _) => const SizedBox.shrink(),
        errorWidget: (_, _, _) => Center(
          child: AdaptiveIcon(Icons.image_not_supported_outlined, color: color),
        ),
      );
    }

    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            context.go(AppRoutes.guideDetail(entry.kind.name, entry.id)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withValues(alpha: 0.10),
                    color.withValues(alpha: 0.35),
                  ],
                ),
              ),
              child: Padding(
                padding: portrait != null || url == null
                    ? EdgeInsets.zero
                    : const EdgeInsets.fromLTRB(10, 10, 10, 44),
                child: art(),
              ),
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0xCC000000)],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (entry.element != null)
                    _Badge(entry.element!, circle: true),
                  if (entry.weapon != null) ...[
                    const SizedBox(height: 4),
                    _Badge(entry.weapon!),
                  ],
                ],
              ),
            ),
            Positioned(
              left: 8,
              right: 8,
              bottom: 10,
              child: MarqueeText(
                entry.name,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: entry.rarity >= 4 ? 4 : 2,
                decoration: BoxDecoration(
                  color: color,
                  boxShadow: [
                    if (entry.rarity >= 4)
                      BoxShadow(
                        color: color.withValues(alpha: 0.7),
                        blurRadius: 10,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small dark disc holding a game icon; game art is drawn light, so the dark
/// backing keeps it readable in both themes.
class _Badge extends StatelessWidget {
  const _Badge(this.facet, {this.circle = false});

  final GuideFacet facet;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final url = facet.iconUrl;
    if (url == null) return const SizedBox.shrink();
    return Container(
      width: 26,
      height: 26,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black54,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(13),
      ),
      child: CachedNetworkImage(
        imageUrl: url,
        memCacheWidth: 64,
        fadeInDuration: Duration.zero,
        placeholder: (_, _) => const SizedBox.shrink(),
        errorWidget: (_, _, _) => const SizedBox.shrink(),
      ),
    );
  }
}
