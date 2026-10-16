import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// Makes a horizontal scrollable usable with a mouse: the wheel scrolls it
/// sideways and it can be dragged. Both are off by default on desktop, where
/// the wheel only moves vertical scrollables and drag is touch-only.
///
/// The wheel is claimed only while the content can move that way, so at either
/// end it falls through and scrolls the page again. Trackpads and shift+wheel
/// already work natively and are left alone.
class HorizontalScrollArea extends StatefulWidget {
  const HorizontalScrollArea({super.key, required this.builder});

  /// Builds the scrollable; it must use the given controller.
  final Widget Function(BuildContext context, ScrollController controller)
  builder;

  @override
  State<HorizontalScrollArea> createState() => _HorizontalScrollAreaState();
}

class _HorizontalScrollAreaState extends State<HorizontalScrollArea> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !_controller.hasClients) return;
    final delta = event.scrollDelta;
    final shift = HardwareKeyboard.instance.isShiftPressed;
    if (delta.dx != 0 || delta.dy == 0 || shift) return;

    final position = _controller.position;
    final target = (position.pixels + delta.dy).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (target == position.pixels) return;
    GestureBinding.instance.pointerSignalResolver.register(event, (_) {
      _controller.jumpTo(target);
    });
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerSignal: _onPointerSignal,
    child: ScrollConfiguration(
      behavior: ScrollConfiguration.of(context)
          .copyWith(dragDevices: PointerDeviceKind.values.toSet()),
      child: widget.builder(context, _controller),
    ),
  );
}
