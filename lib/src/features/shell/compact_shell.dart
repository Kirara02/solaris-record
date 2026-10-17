import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/routing/app_routes.dart';
import '../../shared/theme/app_tokens.dart';
import '../stats/pool_selection.dart';
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
    // Reads the resolved scheme so AMOLED mode also blackens the navigation.
    final navColor = Theme.of(context).colorScheme.surfaceContainer;
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

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: ClipRect(
        child: AnimatedAlign(
          key: tabBarSlotKey,
          alignment: Alignment.topCenter,
          heightFactor: showTabBar ? 1 : 0,
          duration: context.tokens.motionMedium,
          curve: Curves.easeOutCubic,
          child: ExcludeFocus(
            excluding: !showTabBar,
            child: M3ENavigationBar(
              backgroundColor: navColor,
              selectedIndex: index,
              onDestinationSelected: onSelected,
              destinations: [
                for (final d in destinations)
                  M3ENavigationBarDestination(
                    icon: Icon(d.icon),
                    selectedIcon: d.selectedIcon,
                    label: d.label,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
