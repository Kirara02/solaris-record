import 'package:material_ui/material_ui.dart';

import '../theme/app_tokens.dart';
import '../theme/mornye_icons.dart';

/// Square icon button with a thin outline (toolbar / pager style). An optional
/// [badge] count sits next to the icon, like the filter button's active count.
class OutlinedIconButton extends StatelessWidget {
  const OutlinedIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.badge = 0,
    this.size = 44,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  /// Shown when greater than zero.
  final int badge;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final enabled = onPressed != null;
    final radius = BorderRadius.circular(context.tokens.radiusCover);
    final color = enabled
        ? scheme.onSurface
        : scheme.onSurface.withValues(alpha: 0.38);

    final button = Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: Container(
          constraints: BoxConstraints(minWidth: size, minHeight: size),
          padding: EdgeInsets.symmetric(horizontal: badge > 0 ? 10 : 0),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: enabled ? 1 : 0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AdaptiveIcon(icon, size: 20, color: color),
              if (badge > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.onSurface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$badge',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.surface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
