import 'package:flutter/cupertino.dart' show CupertinoSwitch;
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_tokens.dart';
import '../theme/mornye_icons.dart';
import '../theme/mornye_theme.dart';

/// Surface tint shared by grouped containers: the page surface nudged toward
/// black (light) or white (dark), so groups read as raised without shadows.
Color groupColor(BuildContext context) {
  final theme = Theme.of(context);
  // Inset grouped: white (or system gray) rows on the grey page.
  if (context.isMornye) return theme.colorScheme.surfaceContainer;
  final dark = theme.brightness == Brightness.dark;
  return Color.alphaBlend(
    (dark ? Colors.white : Colors.black).withValues(alpha: dark ? 0.08 : 0.04),
    theme.colorScheme.surface,
  );
}

/// Colour of the line between two rows. Mornye draws its separator at full
/// strength, as iOS does; Material softens it so the group reads as one card.
Color rowDividerColor(BuildContext context) {
  final line = Theme.of(context).colorScheme.outlineVariant;
  return context.isMornye ? line : line.withValues(alpha: 0.3);
}

/// Decoration of a content card on the page: the grouped fill with the card
/// radius. Material adds a hairline outline; Mornye stays flat like an iOS
/// inset group.
BoxDecoration groupDecoration(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return BoxDecoration(
    color: groupColor(context),
    borderRadius: context.tokens.borderRadiusCard,
    border: context.isMornye
        ? null
        : Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
  );
}

/// Whether the rows below are drawn as separate connected tiles, which have
/// gaps instead of dividers.
bool settingsRowsConnected(BuildContext context) =>
    context.dependOnInheritedWidgetOfExactType<_ConnectedRowsScope>() != null;

/// Corners of one tile in a connected list: the card radius at the [first] and
/// [last] ends of the run, tight corners between tiles.
BorderRadius connectedRowRadius(
  BuildContext context, {
  required bool first,
  required bool last,
}) {
  final outer = Radius.circular(context.tokens.radiusCard);
  const inner = Radius.circular(4);
  return BorderRadius.vertical(
    top: first ? outer : inner,
    bottom: last ? outer : inner,
  );
}

class _ConnectedRowsScope extends InheritedWidget {
  const _ConnectedRowsScope({required super.child});

  @override
  bool updateShouldNotify(_ConnectedRowsScope oldWidget) => false;
}

/// Rounded container for a list of [SettingsItem]s or any content. In the
/// Material style a group of plain rows is drawn as connected tiles: one
/// surface per row, a 2dp gap between them, tight inner corners and no
/// dividers. Other content keeps a single outlined card.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    super.key,
    required this.children,
    this.color,
    this.connected = false,
  });

  final List<Widget> children;
  final Color? color;

  /// Connects custom [children] that are each one complete row. Groups made
  /// only of [SettingsItem] and [SettingsSwitchItem] connect without it.
  final bool connected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Forms and custom content stay one card, so spacers never become tiles.
    final standardRows =
        children.isNotEmpty &&
        (connected ||
            children.every(
              (child) => child is SettingsItem || child is SettingsSwitchItem,
            ));
    if (!context.isMornye && standardRows) {
      final tile = color ?? groupColor(context);
      final last = children.length - 1;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: _ConnectedRowsScope(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (index, row) in children.indexed) ...[
                if (index > 0) const SizedBox(height: 2),
                Material(
                  color: tile,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: connectedRowRadius(
                      context,
                      first: index == 0,
                      last: index == last,
                    ),
                  ),
                  child: row,
                ),
              ],
            ],
          ),
        ),
      );
    }
    final border = context.isMornye
        ? BorderSide.none
        : BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5));
    final content = Material(
      type: MaterialType.transparency,
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
    // With reduced motion the group is a plain surface: no M3ECard behaviour.
    if (MediaQuery.disableAnimationsOf(context) || context.isMornye) {
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
    this.badge,
    this.subtitle,
    this.footer,
    this.trailing,
    this.onTap,
    this.showDivider = true,
    this.dividerIndent,
    this.selected,
    this.compact = false,
  });

  final IconData? icon;
  final Color? iconColor;

  /// Replaces [icon] with a custom leading widget (24px wide slot).
  final Widget? leading;
  final String title;
  final TextStyle? titleStyle;

  /// Small label after the title (e.g. a Beta tag).
  final String? badge;
  final String? subtitle;
  final Widget? footer;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  /// Overrides the divider's left inset (defaults to the icon-aligned inset).
  final double? dividerIndent;

  /// Announces a checkmark choice's state to screen readers; null for rows
  /// that are not choices.
  final bool? selected;

  /// Tighter vertical padding for rows that carry a tall trailing control.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final tokens = context.tokens;
    final hasLeading = icon != null || leading != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          selected: selected,
          inMutuallyExclusiveGroup: selected != null,
          child: InkWell(
            onTap: onTap,
            splashColor: scheme.primary.withValues(alpha: 0.12),
            highlightColor: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.rowPaddingH,
                vertical: compact
                    ? tokens.rowPaddingVCompact
                    : tokens.rowPaddingV,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: tokens.rowMinHeight),
                child: Row(
                  children: [
                    if (hasLeading) ...[
                      leading ??
                          AdaptiveIcon(
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
                          if (badge == null)
                            Text(title, style: titleStyle ?? text.bodyLarge)
                          else
                            Wrap(
                              spacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  title,
                                  style: titleStyle ?? text.bodyLarge,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: scheme.primary.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      tokens.radiusBadge,
                                    ),
                                  ),
                                  child: Text(
                                    badge!,
                                    style: TextStyle(
                                      color: scheme.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                      AdaptiveIcon(
                        Icons.chevron_right,
                        size: tokens.rowChevronSize,
                        color: scheme.onSurfaceVariant,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        if (showDivider && !settingsRowsConnected(context))
          Divider(
            height: 1,
            indent:
                dividerIndent ??
                (hasLeading ? tokens.rowIconDividerIndent : tokens.rowPaddingH),
            endIndent: tokens.rowPaddingH,
            color: rowDividerColor(context),
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
    compact: true,
    onTap: onChanged == null ? null : () => onChanged!(!value),
    trailing: context.isMornye
        ? CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: mornyeGreen,
          )
        : MediaQuery.disableAnimationsOf(context)
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
    if (context.isMornye) {
      // iOS footnote header: small, upper case, grey.
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title.toUpperCase(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
      );
    }
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
        color: context.isMornye
            ? isSelected
                  ? scheme.primary.withValues(alpha: 0.14)
                  : scheme.onSurface.withValues(
                      alpha: scheme.brightness == Brightness.dark ? 0.16 : 0.06,
                    )
            : isSelected
            ? scheme.secondaryContainer
            : groupColor(context),
        borderRadius: radius,
        border: Border.all(
          color: isSelected || context.isMornye
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
    final color = context.isMornye
        ? (isSelected ? scheme.primary : scheme.onSurface)
        : isSelected
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
        AdaptiveIcon(icon, color: color),
        const SizedBox(height: 6),
        text,
      ],
    );
  }
}

/// Background and text colours for a [StatusBadge] that tells two kinds of
/// attribute apart (element vs. weapon type). Mornye's container roles are
/// neutral greys, so there the badge is a wash of the primary or tertiary
/// colour instead.
(Color background, Color foreground) attributeBadgeColors(
  BuildContext context, {
  required bool primary,
}) {
  final scheme = Theme.of(context).colorScheme;
  if (context.isMornye) {
    final base = primary ? scheme.primary : scheme.tertiary;
    return (
      Color.alphaBlend(base.withValues(alpha: 0.16), scheme.surfaceContainer),
      base,
    );
  }
  return primary
      ? (scheme.primaryContainer, scheme.onPrimaryContainer)
      : (scheme.tertiaryContainer, scheme.onTertiaryContainer);
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
