import 'package:material_ui/material_ui.dart';

/// One line of text that is centred when it fits and otherwise slides back
/// and forth so the whole name can be read.
class MarqueeText extends StatefulWidget {
  const MarqueeText(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this);
  double _overflow = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Starts (or stops) the loop for [overflow] pixels of hidden text.
  void _sync(double overflow) {
    if (overflow == _overflow) return;
    _overflow = overflow;
    if (overflow <= 0) {
      _controller.stop();
      return;
    }
    // About 30 px/s, plus a pause at each end.
    final travel = (overflow / 30 * 1000).round();
    _controller
      ..duration = Duration(milliseconds: travel * 2 + 2400)
      ..repeat();
  }

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style.merge(widget.style);
    // LayoutBuilder has no intrinsic sizes, which parents like SegmentedButton
    // ask for. A Stack skips positioned children when measuring, so an
    // invisible Text supplies the intrinsics and the marquee fills it.
    return Stack(
      children: [
        ExcludeSemantics(
          child: Opacity(
            opacity: 0,
            child: Text(
              widget.text,
              style: style,
              maxLines: 1,
              softWrap: false,
            ),
          ),
        ),
        Positioned.fill(child: _buildMarquee(style)),
      ],
    );
  }

  Widget _buildMarquee(TextStyle style) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          textDirection: Directionality.of(context),
          maxLines: 1,
        )..layout();
        final overflow = painter.width - constraints.maxWidth;
        final height = painter.height;
        painter.dispose();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _sync(overflow);
        });
        if (overflow <= 0) {
          return Text(widget.text, style: style, textAlign: TextAlign.center);
        }
        final travel = overflow / 30 * 1000;
        final total = travel * 2 + 2400;
        // OverflowBox would fill an unbounded height, so pin it to one line.
        return SizedBox(
          height: height,
          child: ClipRect(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                // hold, slide left, hold, slide back.
                final ms = _controller.value * total;
                final double f;
                if (ms < 600) {
                  f = 0;
                } else if (ms < 600 + travel) {
                  f = (ms - 600) / travel;
                } else if (ms < 1800 + travel) {
                  f = 1;
                } else {
                  f = 1 - (ms - 1800 - travel) / travel;
                }
                return OverflowBox(
                  alignment: Alignment.centerLeft,
                  minWidth: 0,
                  maxWidth: double.infinity,
                  child: Transform.translate(
                    offset: Offset(-overflow * f.clamp(0.0, 1.0), 0),
                    child: child,
                  ),
                );
              },
              child: Text(widget.text, style: style, softWrap: false),
            ),
          ),
        );
      },
    );
  }
}
