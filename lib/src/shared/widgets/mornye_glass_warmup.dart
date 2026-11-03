import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:logging/logging.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/settings/settings_providers.dart';
import '../theme/mornye_theme.dart';
import 'mornye_glass.dart';

/// Prepares the real backdrop pipeline, not just the fragment asset: a glass
/// panel is rasterized once in a detached scene and thrown away, so the first
/// sheet or dialog does not stall compiling the lens.
class MornyeGlassWarmup {
  static Future<void>? _pending;
  static final _log = Logger('glass');

  static Future<void> prepare(ui.FlutterView view) {
    if (!ui.ImageFilter.isShaderFilterSupported) return Future<void>.value();
    return _pending ??= _prepare(view).catchError((Object error) {
      // Preparation is optional: the lens still compiles lazily when needed.
      _log.warning('Glass preparation failed: $error');
    });
  }

  static Future<void> _prepare(ui.FlutterView view) async {
    // GLES needs the view's initialized graphics context. A first-frame
    // callback only means painting was submitted, not that rasterization ran.
    await Future.wait<void>([
      LiquidGlassShaders.ensureLoaded(),
      WidgetsBinding.instance.waitUntilFirstFrameRasterized,
    ]);
    // Do not compete with an entrance, a theme switch or scrolling.
    await SchedulerBinding.instance.scheduleTask(
      () async {
        final binding = WidgetsBinding.instance;
        if (binding.lifecycleState != AppLifecycleState.resumed ||
            !binding.platformDispatcher.views.contains(view)) {
          _pending = null;
          return;
        }
        await _rasterize(view);
      },
      Priority.idle,
      debugLabel: 'Prepare Mornye glass backdrop',
    );
  }
}

Future<void> _rasterize(ui.FlutterView view) async {
  const size = Size(240, 180);
  final boundary = RenderRepaintBoundary();
  final pipeline = PipelineOwner();
  final focus = FocusManager();
  final owner = BuildOwner(focusManager: focus);
  final renderView = RenderView(
    view: view,
    configuration: ViewConfiguration(
      logicalConstraints: BoxConstraints.tight(size),
      physicalConstraints: BoxConstraints.tight(size * view.devicePixelRatio),
      devicePixelRatio: view.devicePixelRatio,
    ),
    child: boundary,
  );
  pipeline.rootNode = renderView;
  renderView.prepareInitialFrame();
  RenderObjectToWidgetElement<RenderBox>? root;
  try {
    root = RenderObjectToWidgetAdapter<RenderBox>(
      container: boundary,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: MediaQueryData(
            size: size,
            devicePixelRatio: view.devicePixelRatio,
          ),
          child: Theme(
            data: MornyeTheme.build(Brightness.dark),
            child: const Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xff76534b), Color(0xff385763)],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12),
                  child: MornyeGlass.overlay(
                    level: MornyeGlassLevel.liquid,
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                    child: Center(child: SizedBox.shrink()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).attachToRenderTree(owner);
    owner.buildScope(root);
    owner.finalizeTree();
    pipeline.flushLayout();
    pipeline.flushCompositingBits();
    pipeline.flushPaint();
    final image = await boundary.toImage(pixelRatio: view.devicePixelRatio);
    image.dispose();
  } finally {
    if (root != null) {
      RenderObjectToWidgetAdapter<RenderBox>(container: boundary)
          .attachToRenderTree(owner, root);
      owner.buildScope(root);
      owner.finalizeTree();
    }
    pipeline.rootNode = null;
    renderView.child = null;
    renderView.dispose();
    boundary.dispose();
    pipeline.dispose();
    focus.dispose();
  }
}

/// Starts the one-time preparation when the full glass is on, including after
/// switching to Mornye or turning the glass on once the app is running.
class MornyeGlassPreparation extends ConsumerWidget {
  const MornyeGlassPreparation({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (context.isMornye &&
        ref.watch(glassLevelProvider) == MornyeGlassLevel.liquid &&
        context.mornye.glassClarity > 0.2 &&
        !context.glassContrastBlocked) {
      unawaited(MornyeGlassWarmup.prepare(View.of(context)));
    }
    return child;
  }
}
