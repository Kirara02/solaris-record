import 'package:material_ui/material_ui.dart';

import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/widgets/app_slider.dart';

/// Picks the echo skill's level (1 to [max]); the skill text and the damage
/// info follow it.
class EchoSkillLevel extends StatelessWidget {
  const EchoSkillLevel({
    super.key,
    required this.level,
    required this.max,
    required this.onChanged,
  });

  final int level;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          context.t.info.level,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$level',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Expanded(
          child: AppSlider(
            min: 1,
            max: max.toDouble(),
            divisions: max - 1,
            value: level.toDouble(),
            label: '$level',
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
      ],
    );
  }
}
