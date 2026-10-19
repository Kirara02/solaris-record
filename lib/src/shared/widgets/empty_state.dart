import 'package:material_ui/material_ui.dart';

import '../theme/mornye_icons.dart';

/// Centered icon + title + body (+ optional action) for empty screens.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.action,
    this.leading,
  });

  final IconData icon;
  final String title;
  final String? body;
  final Widget? action;

  /// Replaces the round icon badge (e.g. with the app logo).
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // The wide shell exposes the rail width as padding, so honor it to center
    // within the body rather than the whole window.
    final pad = MediaQuery.paddingOf(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          32 + pad.left,
          32 + pad.top,
          32 + pad.right,
          32 + pad.bottom,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              leading ??
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: AdaptiveIcon(
                      icon,
                      size: 44,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (body != null) ...[
                const SizedBox(height: 8),
                Text(
                  body!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (action != null) ...[const SizedBox(height: 24), action!],
            ],
          ),
        ),
      ),
    );
  }
}
