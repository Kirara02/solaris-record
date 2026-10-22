import 'package:material_ui/material_ui.dart';

import '../theme/app_tokens.dart';
import 'marquee_text.dart';

/// iOS-style segmented control: a rounded track with a thumb that slides
/// under the selected label.
class MornyeSegmentedControl extends StatelessWidget {
  const MornyeSegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const _height = 36.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final count = labels.length;
    final radius = BorderRadius.circular(context.tokens.radiusControl - 4);
    return Semantics(
      container: true,
      child: Container(
        height: _height,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: scheme.onSurface.withValues(alpha: dark ? 0.16 : 0.07),
          borderRadius: radius,
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : context.tokens.motionMedium,
              curve: Curves.easeOutCubic,
              alignment: Alignment(
                count > 1 ? -1 + 2 * selectedIndex / (count - 1) : 0,
                0,
              ),
              child: FractionallySizedBox(
                widthFactor: 1 / count,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: dark ? const Color(0xFF636366) : Colors.white,
                    borderRadius: radius,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1F000000),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                for (final (i, label) in labels.indexed)
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: i == selectedIndex,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onChanged(i),
                        child: Center(
                          child: MarqueeText(
                            label,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: i == selectedIndex
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
