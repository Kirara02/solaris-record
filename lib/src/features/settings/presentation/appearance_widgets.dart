import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/theme/mornye_icons.dart';
import '../../../shared/theme/mornye_theme.dart';
import '../../../shared/widgets/mornye_glass.dart';
import '../domain/theme_settings.dart';
import '../settings_providers.dart';

/// Round swatches of the iOS system colours for the Mornye accent.
class MornyeAccentPicker extends StatelessWidget {
  const MornyeAccentPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final MornyeAccent selected;
  final ValueChanged<MornyeAccent> onChanged;

  @override
  Widget build(BuildContext context) {
    final a = context.t.appearance;
    final labels = {
      MornyeAccent.red: a.accentRed,
      MornyeAccent.orange: a.accentOrange,
      MornyeAccent.green: a.accentGreen,
      MornyeAccent.teal: a.accentTeal,
      MornyeAccent.blue: a.accentBlue,
      MornyeAccent.purple: a.accentPurple,
      MornyeAccent.pink: a.accentPink,
    };
    final brightness = Theme.of(context).brightness;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final accent in MornyeAccent.values)
            Builder(
              builder: (context) {
                final color = MornyeTheme.accentColor(accent, brightness);
                final foreground =
                    ThemeData.estimateBrightnessForColor(color) ==
                        Brightness.dark
                    ? Colors.white
                    : Colors.black;
                return Semantics(
                  selected: selected == accent,
                  child: IconButton(
                    tooltip: labels[accent],
                    onPressed: () => onChanged(accent),
                    style: IconButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: foreground,
                      minimumSize: const Size.square(48),
                    ),
                    icon: selected == accent
                        ? const AdaptiveIcon(Icons.check)
                        : const SizedBox.square(dimension: 24),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Slider for how clear the Mornye glass is, with a live glass sample over a
/// colour gradient. Needs "Blurred navigation": without blur there is no glass
/// to adjust.
class MornyeGlassClaritySlider extends ConsumerWidget {
  const MornyeGlassClaritySlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = context.t.appearance;
    final clarity = ref.watch(
      themeSettingsControllerProvider.select((s) => s.mornyeGlassClarity),
    );
    final controller = ref.read(themeSettingsControllerProvider.notifier);
    final theme = Theme.of(context);
    final adjustable = ref.watch(navBarBlurProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(a.glassClarity, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(a.glassClaritySubtitle, style: theme.textTheme.bodySmall),
          if (!adjustable) ...[
            const SizedBox(height: 8),
            Text(
              a.glassClarityBlurOff(name: a.navBlur),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 16),
          ExcludeSemantics(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      for (final color in [
                        theme.colorScheme.primary,
                        const Color(0xFF277F94),
                        const Color(0xFFC69756),
                      ])
                        // Light glass over a light backdrop, as in the app:
                        // dense sample colours make white glass look gray.
                        theme.brightness == Brightness.light
                            ? Color.lerp(Colors.white, color, 0.4)!
                            : color,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: MornyeGlass(
                    borderRadius: BorderRadius.circular(22),
                    level: adjustable
                        ? MornyeGlassLevel.frosted
                        : MornyeGlassLevel.flat,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          const AdaptiveIcon(Icons.insights),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              context.t.appearance.styleMornye,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          const AdaptiveIcon(Icons.star),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Slider(
            value: clarity,
            divisions: 20,
            label: '${(clarity * 100).round()}%',
            onChanged: adjustable
                ? (v) => controller.setMornyeGlassClarity(v, persist: false)
                : null,
            onChangeEnd: adjustable ? controller.setMornyeGlassClarity : null,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(a.glassTinted, style: theme.textTheme.bodySmall),
              Text(a.glassClear, style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
