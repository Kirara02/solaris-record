import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/routing/app_routes.dart';
import '../../shared/theme/app_tokens.dart';
import '../../shared/theme/mornye_icons.dart';
import '../../shared/theme/mornye_theme.dart';
import '../../shared/widgets/settings_group.dart';
import '../settings/settings_providers.dart';
import '../stats/pool_selection.dart';
import 'mornye_tab_bar.dart';
import 'nav_destination.dart';

/// Phone layout: a bottom navigation bar that only exists on the tab screens.
/// Detail screens (Appearance, Accounts, ...) use the full height.
///
/// Three tabs: Overview and Convene share the stats branch (the selected pull
/// type decides which one is showing), Settings is the second branch.
class CompactShell extends ConsumerWidget {
  const CompactShell({
    super.key,
    required this.navigationShell,
    required this.location,
    required this.destinations,
  });

  final StatefulNavigationShell navigationShell;
  final String location;
  final List<NavDestination> destinations;

  /// Key of the bottom bar's slot, so tests can measure its height.
  static const tabBarSlotKey = ValueKey('tab-bar-slot');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final blur = ref.watch(navBarBlurProvider);
    final pool = ref.watch(selectedPoolProvider);
    final branch = navigationShell.currentIndex;
    final index = branch == 0 ? (pool == null ? 0 : 1) : 2;

    void onSelected(int i) {
      final selection = ref.read(selectedPoolProvider.notifier);
      if (i == 2) {
        navigationShell.goBranch(1, initialLocation: branch == 1);
        return;
      }
      if (i == 0) {
        selection.select(null);
      } else {
        selection.selectConvene();
      }
      navigationShell.goBranch(0, initialLocation: branch == 0 && index == i);
    }

    final showTabBar = isTabRoot(location);

    // The bar paints one tint across the controls and the gesture area, with
    // a hairline on top. With blur it is translucent over a blurred backdrop
    // and the body extends under it (screens add the bar's height as bottom
    // padding); without, it is the same colour opaque.
    final tint = groupColor(context);
    Widget bar = context.isMornye
        ? MornyeTabBar(
            destinations: destinations,
            selectedIndex: index,
            onSelected: onSelected,
            blur: blur,
          )
        : DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: scheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: ColoredBox(
              color: blur ? tint.withValues(alpha: 0.72) : tint,
              child: SafeArea(
                top: false,
                child: M3ENavigationBar(
                  size: M3ENavBarSize.small,
                  autoLayout: false,
                  safeArea: false,
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                  selectedIndex: index,
                  onDestinationSelected: onSelected,
                  destinations: [
                    for (final d in destinations)
                      M3ENavigationBarDestination(
                        icon: AdaptiveIcon(d.icon),
                        selectedIcon: d.selectedIcon,
                        label: d.label,
                      ),
                  ],
                ),
              ),
            ),
          );
    if (blur && !context.isMornye) {
      bar = ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          blendMode: BlendMode.src,
          child: bar,
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: ClipRect(
        child: AnimatedAlign(
          key: tabBarSlotKey,
          alignment: Alignment.topCenter,
          heightFactor: showTabBar ? 1 : 0,
          duration: context.tokens.motionMedium,
          curve: Curves.easeOutCubic,
          child: ExcludeFocus(excluding: !showTabBar, child: bar),
        ),
      ),
    );
  }
}
