import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_tokens.dart';

/// Surface tint shared by grouped containers: the page surface nudged toward
/// black (light) or white (dark), so groups read as raised without shadows.
Color groupColor(BuildContext context) {
  final theme = Theme.of(context);
  final dark = theme.brightness == Brightness.dark;
  return Color.alphaBlend(
    (dark ? Colors.white : Colors.black).withValues(alpha: dark ? 0.08 : 0.04),
    theme.colorScheme.surface,
  );
}

/// Rounded, outlined container for a list of [SettingsItem]s or any content.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.children, this.color});

  final List<Widget> children;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final border = BorderSide(
      color: scheme.outlineVariant.withValues(alpha: 0.5),
    );
    final content = Material(
      type: MaterialType.transparency,
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
    // With reduced motion the group is a plain surface: no M3ECard behaviour.
    if (MediaQuery.disableAnimationsOf(context)) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: color ?? groupColor(context),
            borderRadius: context.tokens.borderRadiusCard,
            border: Border.fromBorderSide(border),
          ),
          child: content,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        width: double.infinity,
        child: M3ECard(
          variant: M3ECardVariant.filled,
          color: color ?? groupColor(context),
          padding: EdgeInsets.zero,
          elevation: 0,
          border: border,
          borderRadius: context.tokens.borderRadiusCard,
          child: content,
        ),
      ),
    );
  }
}

/// One row of a [SettingsGroup]: optional leading icon, title, subtitle,
/// footer, trailing widget, and a chevron when tappable.
class SettingsItem extends StatelessWidget {
  const SettingsItem({
    super.key,
    this.icon,
    this.iconColor,
    this.leading,
    required this.title,
    this.titleStyle,
    this.subtitle,
    this.footer,
    this.trailing,
    this.onTap,
    this.showDivider = true,
    this.dividerIndent,
  });

  final IconData? icon;
  final Color? iconColor;

  /// Replaces [icon] with a custom leading widget (24px wide slot).
  final Widget? leading;
  final String title;
  final TextStyle? titleStyle;
  final String? subtitle;
  final Widget? footer;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  /// Overrides the divider's left inset (defaults to the icon-aligned inset).
  final double? dividerIndent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final tokens = context.tokens;
    final hasLeading = icon != null || leading != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          splashColor: scheme.primary.withValues(alpha: 0.12),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.rowPaddingH,
              vertical: tokens.rowPaddingV,
            ),
            child: Row(
              children: [
                if (hasLeading) ...[
                  leading ??
                      Icon(
                        icon,
                        color: iconColor ?? scheme.onSurfaceVariant,
                        size: 24,
                      ),
                  SizedBox(width: tokens.rowIconGap),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: titleStyle ?? text.bodyLarge),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: text.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      if (footer != null) ...[
                        const SizedBox(height: 8),
                        footer!,
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ] else if (onTap != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    size: 24,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent:
                dividerIndent ??
                (hasLeading ? tokens.rowIconDividerIndent : tokens.rowPaddingH),
            endIndent: tokens.rowPaddingH,
            color: scheme.outlineVariant.withValues(alpha: 0.3),
          ),
      ],
    );
  }
}

/// A [SettingsItem] with a trailing expressive switch.
class SettingsSwitchItem extends StatelessWidget {
  const SettingsSwitchItem({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  final IconData? icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool showDivider;

  @override
  Widget build(BuildContext context) => SettingsItem(
    icon: icon,
    title: title,
    subtitle: subtitle,
    showDivider: showDivider,
    onTap: onChanged == null ? null : () => onChanged!(!value),
    trailing: MediaQuery.disableAnimationsOf(context)
        ? Switch(value: value, onChanged: onChanged)
        : M3ESwitch(value: value, onChanged: onChanged, semanticLabel: title),
  );
}

/// Small primary-coloured heading above a [SettingsGroup].
class SettingsSectionHeader extends StatelessWidget {
  const SettingsSectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Selectable pill used for pool filters.
class SettingsChoiceChip extends StatelessWidget {
  const SettingsChoiceChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  /// When set, the icon is stacked above the label (used for mode pickers).
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(context.tokens.radiusControl);
    return AnimatedContainer(
      duration: context.tokens.motionFast,
      decoration: BoxDecoration(
        color: isSelected ? scheme.secondaryContainer : groupColor(context),
        borderRadius: radius,
        border: Border.all(
          color: isSelected
              ? Colors.transparent
              : scheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: icon == null ? 10 : 14,
            ),
            child: _content(context, scheme),
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, ColorScheme scheme) {
    final color = isSelected
        ? scheme.onSecondaryContainer
        : scheme.onSurfaceVariant;
    final text = Text(
      label,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: color,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
    );
    if (icon == null) return text;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 6),
        text,
      ],
    );
  }
}

/// Compact tinted label for statuses (Won 50/50, Active, ...).
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.background,
    this.foreground,
  });

  final String label;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background ?? scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(context.tokens.radiusBadge + 4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: foreground ?? scheme.onSecondaryContainer,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
