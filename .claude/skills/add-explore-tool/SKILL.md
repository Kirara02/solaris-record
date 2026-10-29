---
name: add-explore-tool
description: Add a new tool or screen to the Explore tab of Solaris Record (phone Explore list and wide-layout rail group). Use when adding an Explore entry, tool screen, or a route under /explore.
---

# Add an Explore tool

Touch points, in order:

1. **Screen**: `lib/src/features/<name>/presentation/`. A `CustomScrollView` with content slivers wrapped in `SliverAdaptivePadding`. Drop the back arrow on wide layouts; follow `TowerScreen` / `RedeemScreen`.
2. **Route constant**: `lib/src/shared/routing/app_routes.dart` (`/explore/<name>`).
3. **Route**: a child `GoRoute` under `AppRoutes.explore` in `lib/src/shared/routing/app_router.dart`, built with `_subPage`.
4. **Phone list**: add an `item(...)` in `lib/src/features/explore/presentation/explore_screen.dart`. Icons go through `AdaptiveIcon`; register any new `Icons.*` in `lib/src/shared/theme/mornye_icons.dart`.
5. **Wide rail**: add the entry to the Explore group in `lib/src/features/shell/wide_shell.dart` (rail indexes: Overview, then the open pull types, then the open Explore group).
6. **Strings**: `explore.<name>` and `explore.<name>Desc` via the `add-i18n-string` skill.
7. **Data from an API**: a service with a disk cache and lenient parsers, plus an `@riverpod` provider in a `*_providers.dart` file; then `dart run build_runner build`. Show item names with `ItemName`, not `record.name`.
8. Verify with `flutter analyze`. Do not add tests unless asked.

Background: `CLAUDE.md` (Explore tab entry).
