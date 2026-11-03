import 'dart:math' as math;
import 'dart:ui';

import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/mornye_theme.dart';
import 'mornye_squircle_border.dart';

/// How a [MornyeGlass] surface is drawn.
enum MornyeGlassLevel {
  /// Solid fill only, no backdrop sampling (cheap; also the "no blur"
  /// setting).
  flat,

  /// Backdrop blur under a translucent fill.
  frosted,

  /// Refractive glass from `liquid_glass_easy`. Without shader filters
  /// (Skia, web) it falls back to the frosted look.
  liquid,
}

/// A glass surface, drawn the way the Mornye app draws it: a tinted fill over
/// a blurred (or, for [MornyeGlassLevel.liquid], refracted) backdrop, a soft
/// contact shadow and a lit hairline rim. Use it for bars, sheets and dialogs,
/// not for list items. Glass inside glass never samples the backdrop again.
class MornyeGlass extends StatelessWidget {
  const MornyeGlass({
    super.key,
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.level = MornyeGlassLevel.frosted,
    this.fill,
    this.tintOpacity = 0.6,
    this.samplesBackdrop = true,
    this.highlightBorder = false,
    this.highlightIntensity = 1,
    this.smoothCorners = false,
  });

  /// Dialogs, sheets and menus: the stronger tint of Mornye's overlay glass.
  const MornyeGlass.overlay({
    super.key,
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.level = MornyeGlassLevel.frosted,
    this.fill,
    this.tintOpacity = 0.78,
    this.samplesBackdrop = true,
    this.highlightBorder = false,
    this.highlightIntensity = 1,
    this.smoothCorners = false,
  });

  // Quantized and shared across surfaces, so a clarity change never builds a
  // new Gaussian filter per frame.
  static const _blurSigmas = [2.0, 3.0, 6.0, 16.0];
  static final _blurs = [
    for (final sigma in _blurSigmas)
      ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
  ];

  final Widget child;
  final BorderRadius borderRadius;
  final MornyeGlassLevel level;

  /// Overrides the surface colour the tint is built on.
  final Color? fill;

  /// How opaque the tint is before the clarity setting thins it.
  final double tintOpacity;

  /// False on a plain page (a settings card, say): the tint stays but nothing
  /// is blurred or refracted, since there is nothing behind to filter.
  final bool samplesBackdrop;

  /// Paints the rim above the fill with a brighter light, so a tinted menu or
  /// floating bar keeps a visible edge. The lens' own rim is kept too.
  final bool highlightBorder;

  /// Scales the rim light and the lens' highlights.
  final double highlightIntensity;

  /// Continuous (squircle) corners, as iOS draws them, instead of circular
  /// arcs. Only for a surface with one radius on all four corners.
  final bool smoothCorners;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = scheme.brightness == Brightness.dark;
    final style = context.mornye;
    final clarity = style.glassClarity;
    final outlines = style.glassOutlines;
    final base = fill ?? scheme.surfaceContainerHigh;

    // Like the system, drop the see-through effects when the user asks for
    // more contrast: a plain fill stays readable.
    final translucent =
        level != MornyeGlassLevel.flat &&
        clarity > 0 &&
        !context.glassContrastBlocked;

    var tint = base;
    if (translucent) {
      var baseTint = (dark ? base : Colors.white).withValues(
        alpha: dark ? tintOpacity * 0.82 : (tintOpacity * 0.88).clamp(0.5, 1.0),
      );
      if (dark) {
        // Bound bright content with paint instead of filtering its luma.
        baseTint = Color.alphaBlend(
          baseTint,
          Colors.black.withValues(alpha: 0.35),
        );
      }
      // The upper end of the clarity slider reveals more of the page.
      final tintStrength = (1 - clarity) * (1 - clarity);
      tint = Color.alphaBlend(base.withValues(alpha: tintStrength), baseTint);
    }

    final insideGlass =
        context.dependOnInheritedWidgetOfExactType<_GlassBackdropScope>() !=
        null;
    // At low clarity the tint hides almost all detail, so sampling the
    // backdrop would only cost.
    final blurThreshold = level == MornyeGlassLevel.frosted ? 0.5 : 0.2;
    final sampleBackdrop =
        translucent &&
        samplesBackdrop &&
        !insideGlass &&
        clarity > blurThreshold;
    final useLens =
        sampleBackdrop &&
        level == MornyeGlassLevel.liquid &&
        ImageFilter.isShaderFilterSupported;
    final filterIndex = level == MornyeGlassLevel.frosted
        ? 1
        : clarity >= 0.9
        ? 0
        : clarity >= 0.6
        ? 2
        : 3;
    final clearFill = (dark ? const Color(0xff999999) : Colors.white)
        .withValues(alpha: dark ? 0.17 : 0.46);
    final fillColor = useLens
        ? Color.lerp(tint, clearFill, ((clarity - 0.2) / 0.8).clamp(0, 1))
        : tint;

    final squircle = smoothCorners;
    final radius = borderRadius.topLeft.x;
    final surface = DecoratedBox(
      decoration: squircle
          ? ShapeDecoration(
              color: fillColor,
              shape: MornyeSquircleBorder(radius),
            )
          : BoxDecoration(color: fillColor, borderRadius: borderRadius),
      // Controls paint on this surface; never re-blur their parent. The
      // transparent Material lets ink (ListTile, InkWell) paint above the tint
      // instead of beneath it: without one, the fill hides their splashes and
      // Flutter reports "ListTile background color or ink splashes may be
      // invisible".
      child: _GlassBackdropScope(
        child: Material(type: MaterialType.transparency, child: child),
      ),
    );
    final Widget backdrop;
    if (useLens) {
      final lens = MornyeLiquidBackdrop(
        borderRadius: borderRadius,
        clarity: clarity,
        blurSigma: _blurSigmas[filterIndex],
        highlightIntensity: highlightIntensity,
        smoothCorners: squircle,
        child: surface,
      );
      // Outside a batch the lens takes a backdrop key of its own: sharing one
      // with the page or an overlapping menu would lose their glass.
      backdrop = LiquidGlassBatch.backdropIdOf(context) == null
          ? LiquidGlassBatch(child: lens)
          : lens;
    } else if (sampleBackdrop) {
      backdrop = BackdropFilter.grouped(
        filter: _blurs[filterIndex],
        child: surface,
      );
    } else {
      backdrop = surface;
    }

    final shadows = [
      BoxShadow(
        color: Colors.black.withValues(alpha: dark ? 0.14 : 0.08),
        blurRadius: 8,
        blurStyle: BlurStyle.outer,
        offset: const Offset(0, 2),
      ),
    ];
    return DecoratedBox(
      decoration: squircle
          ? ShapeDecoration(
              shape: MornyeSquircleBorder(radius),
              shadows: shadows,
            )
          : BoxDecoration(borderRadius: borderRadius, boxShadow: shadows),
      child: CustomPaint(
        // The lens already draws its own rim; a second contact stroke on top
        // would show against light pages.
        foregroundPainter: outlines && (!useLens || highlightBorder)
            ? _GlassRimPainter(
                shape: borderRadius,
                illuminated: translucent && (!useLens || highlightBorder),
                emphasized: highlightBorder,
                dark: dark,
                intensity: highlightIntensity,
                smoothCorners: squircle,
              )
            : null,
        child: squircle
            ? ClipPath.shape(
                shape: MornyeSquircleBorder(radius),
                child: backdrop,
              )
            : ClipRRect(borderRadius: borderRadius, child: backdrop),
      ),
    );
  }
}

class _GlassBackdropScope extends InheritedWidget {
  const _GlassBackdropScope({required super.child});

  @override
  bool updateShouldNotify(_GlassBackdropScope oldWidget) => false;
}

/// A bounded package lens that refracts the (blurred) backdrop behind it.
///
/// With [interaction] it is the lens held over a selection: [progress] scales
/// the bend, the rim and the colour split from 0 (nothing drawn) to 1.
class MornyeLiquidBackdrop extends StatelessWidget {
  const MornyeLiquidBackdrop({
    super.key,
    required this.borderRadius,
    required this.clarity,
    required this.blurSigma,
    required this.child,
    this.interaction = false,
    this.progress = 1,
    this.refractionDepth = 0.30,
    this.refractionWidth = 20,
    this.highlightIntensity = 1,
    this.smoothCorners = false,
  });

  final BorderRadius borderRadius;
  final double clarity;
  final double blurSigma;
  final Widget child;
  final bool interaction;
  final double progress;
  final double refractionDepth;
  final double refractionWidth;
  final double highlightIntensity;
  final bool smoothCorners;

  @override
  Widget build(BuildContext context) {
    if (interaction && progress <= 0) return child;
    final effect = interaction ? progress : 1.0;
    final outlines = context.mornye.glassOutlines;
    final dark = Theme.of(context).brightness == Brightness.dark;
    // The package fixes the bend's travel at 70 logical pixels and controls
    // it through the refraction index alone.
    final edgeBend =
        math.sqrt(1 - 1 / (1.7 * 1.7)) *
        refractionWidth *
        refractionDepth *
        effect *
        5 /
        70;
    final index = 1 / math.sqrt(1 - math.pow(edgeBend.clamp(0, 0.95), 2));
    return LiquidGlassLens(
      style: LiquidGlassStyle(
        shape: LiquidGlassShape(
          cornerStyle: smoothCorners
              ? LiquidGlassCornerStyle.squircle
              : LiquidGlassCornerStyle.roundedRectangle,
          clipQuality: smoothCorners
              ? LiquidGlassClipQuality.exact
              : LiquidGlassClipQuality.roundedRectangle,
          cornerRadius: borderRadius.topLeft.x,
        ),
        specular: LiquidGlassLight.specular(
          thickness: outlines ? 0.75 * 5.4 : 0,
          angle: 0,
          spread: 0.2,
          intensity: outlines
              ? (dark ? 0.25 : 0.12) * effect * highlightIntensity
              : 0,
          color: dark ? Colors.white : const Color(0x88ffffff),
        ),
        glow: LiquidGlassLight.glow(
          thickness: outlines ? 0.75 * 29.4 : 0,
          intensity: outlines ? 0.05 * highlightIntensity : 0,
        ),
        blur: blurSigma,
        refractionIndex: index,
        refractionWidth: refractionWidth,
        dispersion: 1.32 * clarity * effect,
      ),
      child: child,
    );
  }
}

/// Edge definition without another offscreen layer or backdrop read: a thin
/// contact line plus a rim light that fades from the top to the bottom.
class _GlassRimPainter extends CustomPainter {
  const _GlassRimPainter({
    required this.shape,
    required this.illuminated,
    required this.emphasized,
    required this.dark,
    required this.intensity,
    required this.smoothCorners,
  });

  final BorderRadius shape;
  final bool smoothCorners;
  final bool illuminated;
  final bool emphasized;
  final bool dark;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final bounds = Offset.zero & size;
    final outline = shape.toRRect(bounds);
    void stroke(double inset, Paint paint) {
      if (smoothCorners) {
        canvas.drawPath(
          MornyeSquircleBorder(
            (shape.topLeft.x - inset).clamp(0, double.infinity),
          ).getOuterPath(bounds.deflate(inset)),
          paint,
        );
      } else {
        canvas.drawRRect(outline.deflate(inset), paint);
      }
    }

    stroke(
      0.25,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = Colors.black.withValues(alpha: dark ? 0.5 : 0.16),
    );
    if (illuminated) {
      final colors = [
        Color(emphasized ? 0x88ffffff : 0x40ffffff),
        Color(emphasized ? 0x26ffffff : 0x0dffffff),
        const Color(0x0a000000),
        Color(emphasized ? 0x20ffffff : 0x0dffffff),
        Color(emphasized ? 0x55ffffff : 0x26ffffff),
      ];
      stroke(
        0.8,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = emphasized ? 1 : 0.6
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0, 0.14, 0.5, 0.86, 1],
            colors: [
              for (final color in colors)
                color.withValues(alpha: color.a * intensity),
            ],
          ).createShader(bounds),
      );
    }
  }

  @override
  bool shouldRepaint(_GlassRimPainter oldDelegate) =>
      shape != oldDelegate.shape ||
      illuminated != oldDelegate.illuminated ||
      emphasized != oldDelegate.emphasized ||
      smoothCorners != oldDelegate.smoothCorners ||
      dark != oldDelegate.dark ||
      intensity != oldDelegate.intensity;
}
