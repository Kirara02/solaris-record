import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/accounts/presentation/accounts_screen.dart';
import '../../features/settings/presentation/about_screen.dart';
import '../../features/settings/presentation/appearance_screen.dart';
import '../../features/settings/presentation/data_screen.dart';
import '../../features/settings/presentation/logs_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/stats/presentation/stats_screen.dart';
import '../../features/update/presentation/update_startup_check.dart';
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
  final router = GoRouter(
    initialLocation: AppRoutes.convene,
    errorPageBuilder: (context, state) => _page(state, const _NotFound()),
    routes: [
      StatefulShellRoute.indexedStack(
        pageBuilder: (context, state, shell) => _page(
          state,
          UpdateStartupCheck(
            child: AppShell(navigationShell: shell, location: state.uri.path),
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
        child: const Icon(Icons.home),
      ),
    ),
  );
}
