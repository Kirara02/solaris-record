import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/i18n/gen/strings.g.dart';
import '../../shared/layout/window_size.dart';
import '../../shared/theme/mornye_icons.dart';
import 'animated_nav_icons.dart';
import 'compact_shell.dart';
import 'nav_destination.dart';
import 'wide_shell.dart';

/// Picks the base layout for the window size: [CompactShell] (bottom bar) on
/// phones, [WideShell] (rail, Settings at the bottom) on tablets and desktops.
/// The screens inside are the same widgets either way.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
    required this.location,
  });

  final StatefulNavigationShell navigationShell;

  /// Current full path; decides whether the phone's bottom bar is shown.
  final String location;

  /// Key of the phone bottom bar's slot, so tests can measure its height.
  static const tabBarSlotKey = CompactShell.tabBarSlotKey;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    // Each tab animates its selected icon when it is chosen. The last
    // destination is the one the wide layout pins to the bottom.
    final settings = NavDestination(
      icon: Icons.settings_outlined,
      selectedIcon: const SpinIcon(child: AdaptiveIcon(Icons.settings)),
      label: t.nav.settings,
    );
    final overview = NavDestination(
      icon: Icons.dashboard_outlined,
      selectedIcon: const BouncingIcon(child: AdaptiveIcon(Icons.dashboard)),
      label: t.nav.overview,
    );
    // Phones: Overview, Convene (with its pull-type chips) and Settings. Wide
    // layouts: Overview with the pull types nested under it in the rail.
    final compactDestinations = [
      overview,
      NavDestination(
        icon: Icons.insights_outlined,
        selectedIcon: const BouncingIcon(child: AdaptiveIcon(Icons.insights)),
        label: t.nav.stats,
      ),
      settings,
    ];
    final wideDestinations = [overview, settings];

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = WindowSize.fromWidth(constraints.maxWidth);
        if (size == WindowSize.compact) {
          return CompactShell(
            navigationShell: navigationShell,
            location: location,
            destinations: compactDestinations,
          );
        }
        return WideShell(
          navigationShell: navigationShell,
          destinations: wideDestinations,
          size: size,
        );
      },
    );
  }
}
