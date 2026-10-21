import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/assets/assets.gen.dart';
import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/layout/window_size.dart';
import '../../../shared/routing/app_routes.dart';
import '../../../shared/theme/mornye_icons.dart';
import '../../../shared/widgets/app_sliver_header.dart';
import '../../../shared/widgets/settings_group.dart';

/// The Explore tab: a list of tools and guides. Add a row by adding an item
/// here and a route in `app_router.dart`.
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  /// Key of the row that opens [route], for tests.
  static ValueKey<String> tileKey(String route) => ValueKey('explore-$route');

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final scheme = Theme.of(context).colorScheme;

    Widget item(
      IconData icon,
      String title,
      String subtitle,
      String route, {
      bool last = false,
      AssetGenImage? art,
    }) => SettingsItem(
      key: tileKey(route),
      icon: art == null ? icon : null,
      leading: art == null ? null : _ArtIcon(art),
      iconColor: scheme.primary,
      title: title,
      subtitle: subtitle,
      showDivider: !last,
      trailing: const AdaptiveIcon(Icons.chevron_right),
      onTap: () => context.go(route),
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          AppSliverHeader(title: t.explore.title),
          SliverAdaptivePadding(
            sliver: SliverMainAxisGroup(
              slivers: [
                SliverToBoxAdapter(
                  child: SettingsSectionHeader(title: t.explore.tools),
                ),
                SliverToBoxAdapter(
                  child: SettingsGroup(
                    children: [
                      item(
                        Icons.menu_book_outlined,
                        t.explore.guide,
                        t.explore.guideDesc,
                        AppRoutes.guide,
                      ),
                      item(
                        Icons.fort_outlined,
                        t.explore.tower,
                        t.explore.towerDesc,
                        AppRoutes.tower,
                        art: Assets.images.exploreTower,
                      ),
                      item(
                        Icons.water_outlined,
                        t.explore.whiwa,
                        t.explore.whiwaDesc,
                        AppRoutes.whiwa,
                        art: Assets.images.exploreWhiwa,
                      ),
                      item(
                        Icons.grid_view,
                        t.explore.matrix,
                        t.explore.matrixDesc,
                        AppRoutes.matrix,
                        art: Assets.images.exploreMatrix,
                      ),
                      item(
                        Icons.card_giftcard_outlined,
                        t.explore.redeem,
                        t.explore.redeemDesc,
                        AppRoutes.redeem,
                        last: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Game artwork for a row's leading slot. The art is drawn light, so a dark
/// disc keeps it readable in both themes.
class _ArtIcon extends StatelessWidget {
  const _ArtIcon(this.art);

  final AssetGenImage art;

  @override
  Widget build(BuildContext context) => Container(
    width: 28,
    height: 28,
    padding: const EdgeInsets.all(3),
    decoration: const BoxDecoration(
      color: Colors.black87,
      shape: BoxShape.circle,
    ),
    child: art.image(fit: BoxFit.contain, filterQuality: FilterQuality.medium),
  );
}
