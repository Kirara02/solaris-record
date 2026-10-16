import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solaris_record_app/src/features/shell/animated_nav_icons.dart';
import 'package:solaris_record_app/src/features/shell/app_shell.dart';
import 'package:solaris_record_app/src/shared/routing/app_routes.dart';

import '../../support/app_harness.dart';

double barHeight(WidgetTester tester) =>
    tester.getSize(find.byKey(AppShell.tabBarSlotKey)).height;

void main() {
  test('only the tab roots count as tab screens', () {
    for (final path in ['/convene', '/settings', '/settings/']) {
      expect(isTabRoot(path), isTrue, reason: path);
    }
    for (final path in [
      '/settings/appearance',
      '/settings/accounts',
      '/settings/data',
      '/settings/about',
      '/import',
      '/nope',
      '',
    ]) {
      expect(isTabRoot(path), isFalse, reason: path);
    }
  });

  testWidgets('phone: bottom bar shows on tabs and hides on detail screens', (
    tester,
  ) async {
    final router = await pumpApp(tester, size: const Size(412, 915));
    expect(barHeight(tester), greaterThan(40));

    router.go(AppRoutes.settings);
    await tester.pump(const Duration(seconds: 1));
    expect(barHeight(tester), greaterThan(40));

    for (final route in [
      AppRoutes.appearance,
      AppRoutes.accounts,
      AppRoutes.data,
      AppRoutes.about,
    ]) {
      router.go(route);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(barHeight(tester), 0, reason: route);
    }

    // Back on a tab root the bar returns.
    router.go(AppRoutes.settings);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(barHeight(tester), greaterThan(40));
    await disposeApp(tester);
  });

  testWidgets('wide screens use the rail instead of the bottom bar', (
    tester,
  ) async {
    final router = await pumpApp(tester, size: const Size(1360, 860));
    expect(find.byKey(AppShell.tabBarSlotKey), findsNothing);
    router.go(AppRoutes.appearance);
    await tester.pump(const Duration(seconds: 1));
    expect(find.byKey(AppShell.tabBarSlotKey), findsNothing);
    await disposeApp(tester);
  });

  group('selected icon animations', () {
    double? turns(WidgetTester tester) => tester
        .widget<RotationTransition>(
          find.descendant(
            of: find.byType(SpinIcon),
            matching: find.byType(RotationTransition),
          ),
        )
        .turns
        .value;

    testWidgets('settings cog spins half a turn when selected', (tester) async {
      await pumpApp(tester, size: const Size(412, 915));
      expect(find.byType(SpinIcon), findsNothing);

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pump(); // selection rebuild mounts the animated icon
      expect(find.byType(SpinIcon), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 150));
      final mid = turns(tester)!;
      expect(mid, greaterThan(0));
      expect(mid, lessThan(0.5));

      await tester.pump(const Duration(milliseconds: 700));
      expect(turns(tester), closeTo(0.5, 1e-6));
      await disposeApp(tester);
    });

    testWidgets('each tab plays its own animation on selection', (
      tester,
    ) async {
      await pumpApp(tester, size: const Size(412, 915));
      // Convene starts selected: its icon is the bouncing one.
      expect(find.byType(BouncingIcon), findsOneWidget);
      expect(find.byType(SpinIcon), findsNothing);

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pump();
      expect(find.byType(SpinIcon), findsOneWidget);
      expect(find.byType(BouncingIcon), findsNothing);
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byIcon(Icons.insights_outlined));
      await tester.pump();
      expect(find.byType(BouncingIcon), findsOneWidget);
      expect(find.byType(SpinIcon), findsNothing);
      await tester.pump(const Duration(seconds: 1));
      await disposeApp(tester);
    });

    testWidgets('Overview, Convene and Settings are tabs', (tester) async {
      await pumpApp(tester, size: const Size(412, 915));
      expect(find.byIcon(Icons.download_outlined), findsNothing);
      expect(find.byIcon(Icons.dashboard), findsOneWidget);
      expect(find.byIcon(Icons.insights_outlined), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
      await disposeApp(tester);
    });
  });
}
