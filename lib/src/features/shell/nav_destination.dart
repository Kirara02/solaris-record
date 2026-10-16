import 'package:material_ui/material_ui.dart';

/// One top-level destination, shared by the phone bar and the wide rail.
class NavDestination {
  const NavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;

  /// Shown when selected; wrapped in that tab's icon animation.
  final Widget selectedIcon;
  final String label;
}
