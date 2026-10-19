import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/layout/content_dialog.dart';
import '../../../shared/layout/window_size.dart';
import '../../../shared/theme/app_tokens.dart';
import '../../../shared/theme/mornye_icons.dart';
import '../../../shared/widgets/app_sliver_header.dart';
import '../../../shared/widgets/horizontal_scroll_area.dart';
import '../../../shared/widgets/mornye_segmented_control.dart';
import '../../../shared/widgets/settings_group.dart';
import '../domain/theme_settings.dart';
import '../settings_providers.dart';
import 'appearance_widgets.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final settings = ref.watch(themeSettingsControllerProvider);
    final controller = ref.read(themeSettingsControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mornye = settings.style == AppThemeStyle.mornye;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          AppSliverHeader(title: t.appearance.title, showBack: true),
          SliverAdaptivePadding(
            sliver: SliverList.list(
              children: [
                SettingsSectionHeader(title: t.appearance.sectionStyle),
                SettingsGroup(
                  children: [
                    for (final (i, option) in [
                      (
                        AppThemeStyle.material,
                        Icons.palette_outlined,
                        t.appearance.styleMaterial,
                      ),
                      (
                        AppThemeStyle.mornye,
                        Icons.blur_on,
                        t.appearance.styleMornye,
                      ),
                    ].indexed)
                      SettingsItem(
                        // The grouped iOS look has no leading icons.
                        icon: mornye ? null : option.$2,
                        title: option.$3,
                        badge: option.$1 == AppThemeStyle.mornye
                            ? t.appearance.beta
                            : null,
                        showDivider: i == 0,
                        trailing: settings.style == option.$1
                            ? AdaptiveIcon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : const SizedBox(width: 24),
                        onTap: () => controller.setStyle(option.$1),
                      ),
                  ],
                ),
                SettingsSectionHeader(title: t.appearance.sectionColor),
                if (mornye)
                  SettingsGroup(
                    children: [
                      MornyeAccentPicker(
                        selected: settings.mornyeAccent,
                        onChanged: controller.setMornyeAccent,
                      ),
                      const MornyeGlassClaritySlider(),
                      SettingsSwitchItem(
                        icon: Icons.rounded_corner,
                        title: t.appearance.glassOutlines,
                        subtitle: t.appearance.glassOutlinesSubtitle,
                        value: settings.mornyeGlassOutlines,
                        onChanged: controller.setMornyeGlassOutlines,
                        showDivider: false,
                      ),
                    ],
                  )
                else ...[
                  SettingsGroup(
                    children: [
                      SettingsSwitchItem(
                        icon: Icons.wallpaper,
                        title: t.appearance.dynamicColor,
                        subtitle: t.appearance.dynamicColorSubtitle,
                        value: settings.useDynamicColor,
                        onChanged: controller.setUseDynamicColor,
                        showDivider: false,
                      ),
                    ],
                  ),
                  if (!settings.useDynamicColor) ...[
                    SettingsSectionHeader(title: t.appearance.accent),
                    _AccentPicker(
                      selected: settings.seedColor,
                      onSelected: controller.setSeedColor,
                    ),
                  ],
                ],
                SettingsSectionHeader(title: t.appearance.sectionTheme),
                SettingsGroup(
                  children: [
                    if (mornye)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: MornyeSegmentedControl(
                          labels: [
                            t.appearance.themeSystem,
                            t.appearance.themeLight,
                            t.appearance.themeDark,
                          ],
                          selectedIndex: switch (settings.mode) {
                            ThemeMode.system => 0,
                            ThemeMode.light => 1,
                            ThemeMode.dark => 2,
                          },
                          onChanged: (i) => controller.setMode(
                            const [
                              ThemeMode.system,
                              ThemeMode.light,
                              ThemeMode.dark,
                            ][i],
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            for (final (i, option) in [
                              (
                                ThemeMode.system,
                                Icons.brightness_auto,
                                t.appearance.themeSystem,
                              ),
                              (
                                ThemeMode.light,
                                Icons.light_mode,
                                t.appearance.themeLight,
                              ),
                              (
                                ThemeMode.dark,
                                Icons.dark_mode,
                                t.appearance.themeDark,
                              ),
                            ].indexed) ...[
                              if (i > 0) const SizedBox(width: 8),
                              Expanded(
                                child: SettingsChoiceChip(
                                  icon: option.$2,
                                  label: option.$3,
                                  isSelected: settings.mode == option.$1,
                                  onTap: () => controller.setMode(option.$1),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    if (isDark && !mornye)
                      SettingsSwitchItem(
                        icon: Icons.brightness_2,
                        title: t.appearance.amoled,
                        subtitle: t.appearance.amoledSubtitle,
                        value: settings.useAmoled,
                        onChanged: controller.setUseAmoled,
                      ),
                    SettingsSwitchItem(
                      icon: Icons.blur_on,
                      title: t.appearance.navBlur,
                      subtitle: t.appearance.navBlurSubtitle,
                      value: ref.watch(navBarBlurProvider),
                      onChanged: ref.read(navBarBlurProvider.notifier).set,
                      showDivider: false,
                    ),
                  ],
                ),
                SettingsSectionHeader(title: t.appearance.sectionLanguage),
                SettingsGroup(
                  children: [
                    SettingsItem(
                      icon: Icons.translate,
                      title: t.appearance.language,
                      subtitle: languageLabel(
                        ref.watch(appLanguageProvider),
                        t,
                      ),
                      onTap: () => _pickLanguage(context, ref),
                    ),
                    SettingsItem(
                      icon: Icons.g_translate,
                      title: t.appearance.dataLanguage,
                      subtitle: dataLanguageLabel(
                        ref.watch(dataLanguageProvider),
                        t,
                      ),
                      showDivider: false,
                      onTap: () => _pickDataLanguage(context, ref),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDataLanguage(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final current = ref.read(dataLanguageProvider);
    final scheme = Theme.of(context).colorScheme;
    final notifier = ref.read(dataLanguageProvider.notifier);

    Widget check(bool on) => on
        ? AdaptiveIcon(Icons.check_circle, color: scheme.primary)
        : const SizedBox(width: 24);

    return showAdaptiveSheet(
      context,
      (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(
              t.appearance.dataLanguage,
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              t.appearance.dataLanguageDesc,
              style: Theme.of(sheetContext).textTheme.bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SettingsGroup(
              children: [
                SettingsItem(
                  icon: Icons.language,
                  title: t.appearance.dataLanguageDefault,
                  subtitle: t.appearance.dataLanguageDefaultSubtitle,
                  trailing: check(current == null),
                  onTap: () {
                    notifier.set(null);
                    Navigator.pop(sheetContext);
                  },
                ),
                for (final (i, code) in dataLanguageNames.keys.indexed)
                  SettingsItem(
                    icon: Icons.language,
                    title: dataLanguageNames[code]!,
                    showDivider: i != dataLanguageNames.length - 1,
                    trailing: check(current == code),
                    onTap: () {
                      notifier.set(code);
                      Navigator.pop(sheetContext);
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final current = ref.read(appLanguageProvider);
    final scheme = Theme.of(context).colorScheme;
    final notifier = ref.read(appLanguageProvider.notifier);

    Widget check(bool on) => on
        ? AdaptiveIcon(Icons.check_circle, color: scheme.primary)
        : const SizedBox(width: 24);

    return showAdaptiveSheet(
      context,
      (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              t.language.title,
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SettingsGroup(
              children: [
                SettingsItem(
                  icon: Icons.phone_android,
                  title: t.language.system,
                  subtitle: t.language.systemSubtitle,
                  trailing: check(current == null),
                  onTap: () {
                    notifier.set(null);
                    Navigator.pop(sheetContext);
                  },
                ),
                for (final (i, code) in languageNames.keys.indexed)
                  SettingsItem(
                    icon: Icons.language,
                    title: languageNames[code]!,
                    showDivider: i != languageNames.length - 1,
                    trailing: check(current == code),
                    onTap: () {
                      notifier.set(code);
                      Navigator.pop(sheetContext);
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Horizontal row of seed-color swatches previewing each palette.
class _AccentPicker extends StatelessWidget {
  const _AccentPicker({required this.selected, required this.onSelected});

  final Color selected;
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return HorizontalScrollArea(
      builder: (context, controller) => SingleChildScrollView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final color in accentChoices)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _Swatch(
                  scheme: ColorScheme.fromSeed(
                    seedColor: color,
                    brightness: brightness,
                  ),
                  selected: color.toARGB32() == selected.toARGB32(),
                  onTap: () => onSelected(color),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.scheme,
    required this.selected,
    required this.onTap,
  });

  final ColorScheme scheme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.tokens.radiusCard);
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: context.tokens.motionFast,
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 3,
            ),
          ),
          padding: const EdgeInsets.all(3),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(context.tokens.radiusCard - 4),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: ColoredBox(
                              color: scheme.primary,
                              child: const SizedBox.expand(),
                            ),
                          ),
                          Expanded(
                            child: ColoredBox(
                              color: scheme.tertiary,
                              child: const SizedBox.expand(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ColoredBox(
                        color: scheme.primaryContainer,
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ],
                ),
                if (selected)
                  Center(
                    child: AdaptiveIcon(
                      Icons.check,
                      color: scheme.onPrimary,
                      size: 26,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
