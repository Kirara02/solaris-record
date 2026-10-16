import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/i18n/gen/strings.g.dart';
import '../../shared/widgets/app_logo.dart';
import 'rail_state.dart';

/// Top of the navigation rail: the app icon with the app name and version.
/// While the rail is compact, or still animating open, only the icon shows.
class RailBrand extends ConsumerWidget {
  const RailBrand({super.key, required this.expanded});

  final bool expanded;

  /// Narrowest width that fits the icon plus the name.
  static const nameMinWidth = 150.0;

  static const _logo = 36.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final version = ref.watch(appVersionProvider).value;

    return LayoutBuilder(
      builder: (context, constraints) {
        final room = expanded && constraints.maxWidth >= nameMinWidth;
        if (!room) {
          return const Padding(
            padding: EdgeInsets.only(top: 4, bottom: 4),
            child: Center(child: AppLogo(size: _logo)),
          );
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(28, 4, 16, 4),
          child: Row(
            children: [
              const AppLogo(size: _logo),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.t.appName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.1,
                      ),
                    ),
                    if (version != null)
                      Text(
                        'v$version',
                        maxLines: 1,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
