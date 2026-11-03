import 'dart:ui';

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
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
import 'chrome_controller.dart';
import 'mornye_tab_bar.dart';
import 'nav_destination.dart';

/// Phone layout: a bottom navigation bar that only exists on the tab screens.
/// Detail screens (Appearance, Accounts, ...) use the full height.
///
/// Four tabs: Overview and Convene share the stats branch (the selected pull
/// type decides which one is showing), Explore and Settings are the next
/// branches.
class CompactShell extends ConsumerStatefulWidget {
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
  ConsumerState<CompactShell> createState() => _CompactShellState();
}

class _CompactShellState extends ConsumerState<CompactShell> {
  static const tabBarSlotKey = CompactShell.tabBarSlotKey;

  final _chrome = ChromeController();

  StatefulNavigationShell get navigationShell => widget.navigationShell;
  String get location => widget.location;
  List<NavDestination> get destinations => widget.destinations;

  @override
  void didUpdateWidget(CompactShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A new tab or page starts with the full bar.
    if (oldWidget.location != widget.location ||
        oldWidget.navigationShell.currentIndex !=
            widget.navigationShell.currentIndex) {
      _chrome.expand();
    }
  }

  @override
  void dispose() {
    _chrome.dispose();
    super.dispose();
  }

  /// The Mornye bar folds on a phone, not on desktop, and not when large text
  /// leaves no room for the single capsule.
  bool _canMinimize(BuildContext context) =>
      context.isMornye &&
      !const {
        TargetPlatform.macOS,
        TargetPlatform.windows,
        TargetPlatform.linux,
      }.contains(defaultTargetPlatform) &&
      MediaQuery.textScalerOf(context).scale(15) <= 20;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final blur = ref.watch(navBarBlurProvider);
    final pool = ref.watch(selectedPoolProvider);
    final branch = navigationShell.currentIndex;
    final index = branch == 0 ? (pool == null ? 0 : 1) : branch + 1;

    void onSelected(int i) {
      _chrome.expand();
      final selection = ref.read(selectedPoolProvider.notifier);
      if (i >= 2) {
        navigationShell.goBranch(i - 1, initialLocation: branch == i - 1);
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
        ? ValueListenableBuilder<bool>(
            valueListenable: _chrome,
            builder: (context, minimized, _) => MornyeTabBar(
              destinations: destinations,
              selectedIndex: index,
              onSelected: onSelected,
              minimized: minimized && _canMinimize(context),
              onExpand: _chrome.expand,
              level: ref.watch(glassLevelProvider),
            ),
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
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) => _canMinimize(context) && showTabBar
            ? _chrome.handleScroll(notification)
            : false,
        child: navigationShell,
      ),
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
