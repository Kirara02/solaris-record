import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/layout/window_size.dart';
import '../../../shared/routing/app_routes.dart';
import '../domain/item_kind.dart';

/// Whether a record has a detail screen (only resonators and weapons do).
bool hasItemInfo(int resourceId, String resourceType) =>
    resourceId > 0 && itemKindFor(resourceId, resourceType) != null;

/// Opens the detail screen of a resonator or weapon, so back returns to where
/// the item was tapped. Phones cover the tab bar; wide layouts use the Guide
/// detail inside the shell, which keeps the sidebar.
void openItemInfo(BuildContext context, int resourceId, String resourceType) {
  final kind = itemKindFor(resourceId, resourceType);
  if (kind == null || resourceId <= 0) return;
  if (context.windowSize == WindowSize.compact) {
    context.push(AppRoutes.itemDetail(kind.name, resourceId));
  } else {
    context.push(AppRoutes.guideDetail(kind.name, resourceId));
  }
}
