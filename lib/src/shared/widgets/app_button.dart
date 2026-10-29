import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_tokens.dart';
import '../theme/mornye_theme.dart';

/// Emphasis of an [AppButton].
enum AppButtonStyle { filled, tonal, outlined, text }

/// A button in the current style: the expressive `M3EButton`, or a flat iOS
/// style button under Mornye (accent fill, accent wash for tonal and
/// outlined, plain accent text).
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = AppButtonStyle.filled,
    this.compact = false,
  });

  final Widget label;
  final Widget? icon;
  final VoidCallback? onPressed;
  final AppButtonStyle style;

  /// A smaller button, for toolbars.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (!context.isMornye) {
      final m3eStyle = switch (style) {
        AppButtonStyle.filled => M3EButtonStyle.filled,
        AppButtonStyle.tonal => M3EButtonStyle.tonal,
        AppButtonStyle.outlined => M3EButtonStyle.outlined,
        AppButtonStyle.text => M3EButtonStyle.text,
      };
      final size = compact ? M3EButtonSize.sm : M3EButtonSize.md;
      // A label without an icon is not rendered by M3EButton, so icon-less
      // buttons pass their text as the child.
      return icon == null
          ? M3EButton(
              style: m3eStyle,
              size: size,
              onPressed: onPressed,
              child: label,
            )
          : M3EButton(
              style: m3eStyle,
              size: size,
              icon: icon,
              label: label,
              onPressed: onPressed,
            );
    }

    final scheme = Theme.of(context).colorScheme;
    final enabled = onPressed != null;
    final (background, foreground) = switch (style) {
      AppButtonStyle.filled => (scheme.primary, scheme.onPrimary),
      AppButtonStyle.tonal => (
        scheme.primary.withValues(alpha: 0.14),
        scheme.primary,
      ),
      AppButtonStyle.outlined => (
        MornyeTheme.controlFill(context),
        scheme.onSurface,
      ),
      AppButtonStyle.text => (Colors.transparent, scheme.primary),
    };
    final disabled = scheme.onSurface.withValues(alpha: 0.38);
    final buttonStyle = ButtonStyle(
      elevation: const WidgetStatePropertyAll(0),
      minimumSize: WidgetStatePropertyAll(Size(0, compact ? 34 : 44)),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: compact ? 14 : 20),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: context.tokens.borderRadiusControl,
        ),
      ),
      backgroundColor: WidgetStatePropertyAll(
        enabled
            ? background
            : style == AppButtonStyle.text
            ? Colors.transparent
            : scheme.onSurface.withValues(alpha: 0.06),
      ),
      foregroundColor: WidgetStatePropertyAll(enabled ? foreground : disabled),
      textStyle: WidgetStatePropertyAll(
        Theme.of(context).textTheme.labelLarge
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
    return icon == null
        ? TextButton(onPressed: onPressed, style: buttonStyle, child: label)
        : TextButton.icon(
            onPressed: onPressed,
            style: buttonStyle,
            icon: icon,
            label: label,
          );
  }
}
