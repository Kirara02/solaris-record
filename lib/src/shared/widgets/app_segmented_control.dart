import 'package:material_ui/material_ui.dart';

import '../theme/mornye_theme.dart';
import 'marquee_text.dart';
import 'mornye_segmented_control.dart';

/// One choice of an [AppSegmentedControl]. The [icon] shows in Material only;
/// the Mornye control is text-only.
class AppSegment<T> {
  const AppSegment({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final Widget? icon;
}

/// A single-choice segmented control in the current style: Material's
/// `SegmentedButton`, or the iOS-style `MornyeSegmentedControl` under Mornye.
class AppSegmentedControl<T> extends StatelessWidget {
  const AppSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  final List<AppSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    if (context.isMornye) {
      return MornyeSegmentedControl(
        labels: [for (final s in segments) s.label],
        selectedIndex: segments
            .indexWhere((s) => s.value == selected)
            .clamp(0, segments.length - 1),
        onChanged: (i) => onChanged(segments[i].value),
      );
    }
    return SegmentedButton<T>(
      showSelectedIcon: false,
      segments: [
        for (final s in segments)
          ButtonSegment(
            value: s.value,
            icon: s.icon,
            label: MarqueeText(s.label),
          ),
      ],
      selected: {selected},
      onSelectionChanged: (v) => onChanged(v.first),
    );
  }
}
