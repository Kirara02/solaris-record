abstract final class AppRoutes {
  static const convene = '/convene';
  static const explore = '/explore';
  static const guide = '/explore/guide';
  static const redeem = '/explore/redeem';
  static const settings = '/settings';
  static const appearance = '/settings/appearance';
  static const accounts = '/settings/accounts';
  static const data = '/settings/data';
  static const logs = '/settings/data/logs';
  static const about = '/settings/about';

  /// Detail screen of one guide entry; [kind] is a `GuideKind` name.
  /// Detail of a resonator or weapon opened from a pull, over the tab bar;
  /// [kind] is a `GuideKind` name.
  static String itemDetail(String kind, int id) => '/item/$kind/$id';

  static String guideDetail(String kind, int id) => '/explore/guide/$kind/$id';
}

/// Paths of the bottom-bar tabs; every other route is a detail screen.
const tabRoots = {AppRoutes.convene, AppRoutes.explore, AppRoutes.settings};

/// Whether [location] is a tab's root screen (a trailing slash is ignored).
bool isTabRoot(String location) {
  final path = location.length > 1 && location.endsWith('/')
      ? location.substring(0, location.length - 1)
      : location;
  return tabRoots.contains(path);
}
