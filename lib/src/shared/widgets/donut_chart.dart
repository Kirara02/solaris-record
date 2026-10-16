import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

class DonutSegment {
  const DonutSegment({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;
}

/// Donut chart with a legend listing each segment's count and share.
class DonutChart extends StatelessWidget {
  const DonutChart({super.key, required this.segments, this.size = 180});

  final List<DonutSegment> segments;
  final double size;

  int get _total => segments.fold(0, (s, e) => s + e.value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final total = _total;
    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _DonutPainter(
              segments: segments,
              track: scheme.surfaceContainerHighest,
              gap: scheme.surface,
            ),
          ),
        ),
        const SizedBox(height: 16),
        for (final s in segments)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: s.color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(s.label, style: theme.textTheme.bodyMedium),
                ),
                Text(
                  '${s.value}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  width: 64,
                  child: Text(
                    total == 0 ? '0%' : '${percentOf(s.value, total)}%',
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Share of [part] in [total] with two decimals ("1.56").
  static String percentOf(int part, int total) =>
      (part * 100 / total).toStringAsFixed(2);
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.segments,
    required this.track,
    required this.gap,
  });

  final List<DonutSegment> segments;
  final Color track;
  final Color gap;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2;
    final stroke = radius * 0.34;
    final rect = Rect.fromCircle(center: center, radius: radius - stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    final total = segments.fold<int>(0, (s, e) => s + e.value);
    if (total == 0) {
      canvas.drawArc(rect, 0, math.pi * 2, false, paint..color = track);
      return;
    }

    var start = -math.pi / 2;
    final visible = segments.where((s) => s.value > 0).toList();
    // A thin gap between slices, unless there is only one.
    final gapAngle = visible.length > 1 ? 0.025 : 0.0;
    for (final s in visible) {
      final sweep = s.value / total * math.pi * 2;
      canvas.drawArc(
        rect,
        start + gapAngle / 2,
        math.max(sweep - gapAngle, 0.001),
        false,
        paint..color = s.color,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.segments != segments || old.track != track;
}
