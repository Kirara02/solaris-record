abstract final class AppRoutes {
  static const convene = '/convene';
  static const settings = '/settings';
  static const appearance = '/settings/appearance';
  static const accounts = '/settings/accounts';
  static const data = '/settings/data';
  static const about = '/settings/about';
}

/// Paths of the bottom-bar tabs; every other route is a detail screen.
const tabRoots = {AppRoutes.convene, AppRoutes.settings};

/// Whether [location] is a tab's root screen (a trailing slash is ignored).
bool isTabRoot(String location) {
  final path = location.length > 1 && location.endsWith('/')
      ? location.substring(0, location.length - 1)
      : location;
  return tabRoots.contains(path);
}
