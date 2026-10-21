import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/accounts/presentation/accounts_screen.dart';
import '../../features/explore/presentation/explore_screen.dart';
import '../../features/guide/domain/guide_entry.dart';
import '../../features/guide/presentation/guide_detail_screen.dart';
import '../../features/guide/presentation/guide_screen.dart';
import '../../features/import/share_intent.dart';
import '../../features/redeem/presentation/redeem_screen.dart';
import '../../features/settings/presentation/about_screen.dart';
import '../../features/settings/presentation/appearance_screen.dart';
import '../../features/settings/presentation/data_screen.dart';
import '../../features/settings/presentation/logs_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/stats/presentation/stats_screen.dart';
import '../../features/update/presentation/update_startup_check.dart';
import '../theme/mornye_icons.dart';
import 'app_routes.dart';

export 'app_routes.dart';

part 'app_router.g.dart';

// Pages are built with the widgets-level NoTransitionPage so routing doesn't
// depend on flutter/material's page transitions (the app uses material_ui).
Page<void> _page(GoRouterState state, Widget child) =>
    NoTransitionPage<void>(key: state.pageKey, child: child);

// Settings sub-pages slide in slightly while fading, using only widgets-level
// transitions.
Page<void> _subPage(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondary, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  // One key per router: a shared one would collide across app instances.
  final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  final router = GoRouter(
    navigatorKey: rootKey,
    initialLocation: AppRoutes.convene,
    errorPageBuilder: (context, state) => _page(state, const _NotFound()),
    routes: [
      GoRoute(
        path: '/item/:kind/:id',
        parentNavigatorKey: rootKey,
        pageBuilder: (c, s) {
          final kind = GuideKind.values.asNameMap()[s.pathParameters['kind']];
          final id = int.tryParse(s.pathParameters['id'] ?? '');
          if (kind == null || kind == GuideKind.echo || id == null) {
            return _page(s, const _NotFound());
          }
          return _subPage(s, GuideDetailScreen(kind: kind, id: id));
        },
      ),
      StatefulShellRoute.indexedStack(
        pageBuilder: (context, state, shell) => _page(
          state,
          ShareIntentListener(
            child: UpdateStartupCheck(
              child: AppShell(navigationShell: shell, location: state.uri.path),
            ),
          ),
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.convene,
                pageBuilder: (c, s) => _page(s, const StatsScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.explore,
                pageBuilder: (c, s) => _page(s, const ExploreScreen()),
                routes: [
                  GoRoute(
                    path: 'guide',
                    pageBuilder: (c, s) => _subPage(s, const GuideScreen()),
                    routes: [
                      GoRoute(
                        path: ':kind/:id',
                        pageBuilder: (c, s) {
                          final kind = GuideKind.values
                              .asNameMap()[s.pathParameters['kind']];
                          final id = int.tryParse(s.pathParameters['id'] ?? '');
                          if (kind == null || id == null) {
                            return _page(s, const _NotFound());
                          }
                          return _subPage(
                            s,
                            GuideDetailScreen(kind: kind, id: id),
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'redeem',
                    pageBuilder: (c, s) => _subPage(s, const RedeemScreen()),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                pageBuilder: (c, s) => _page(s, const SettingsScreen()),
                routes: [
                  GoRoute(
                    path: 'appearance',
                    pageBuilder: (c, s) =>
                        _subPage(s, const AppearanceScreen()),
                  ),
                  GoRoute(
                    path: 'accounts',
                    pageBuilder: (c, s) => _subPage(s, const AccountsScreen()),
                  ),
                  GoRoute(
                    path: 'data',
                    pageBuilder: (c, s) => _subPage(s, const DataScreen()),
                    routes: [
                      GoRoute(
                        path: 'logs',
                        pageBuilder: (c, s) => _subPage(s, const LogsScreen()),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'about',
                    pageBuilder: (c, s) => _subPage(s, const AboutScreen()),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
}

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: TextButton(
        onPressed: () => context.go(AppRoutes.convene),
        child: const AdaptiveIcon(Icons.home),
      ),
    ),
  );
}
