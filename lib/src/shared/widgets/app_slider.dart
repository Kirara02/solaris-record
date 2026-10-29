import 'package:flutter/cupertino.dart' show CupertinoSlider;
import 'package:material_ui/material_ui.dart';

import '../theme/mornye_theme.dart';

/// A slider in the current style: Material's `Slider` (with its value label),
/// or the iOS `CupertinoSlider` under Mornye.
class AppSlider extends StatelessWidget {
  const AppSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    this.label,
  });

  final double value;
  final double min;
  final double max;
  final int? divisions;

  /// Value bubble shown while dragging (Material only).
  final String? label;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) => context.isMornye
      ? CupertinoSlider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: Theme.of(context).colorScheme.primary,
          onChanged: onChanged,
        )
      : Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: label,
          onChanged: onChanged,
        );
}
