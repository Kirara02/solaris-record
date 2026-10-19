import 'dart:ui';

import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/mornye_theme.dart';

/// How a [MornyeGlass] surface is drawn.
enum MornyeGlassLevel {
  /// Translucent fill only, no backdrop blur (cheap; also the "no blur"
  /// setting).
  flat,

  /// Backdrop blur under a translucent fill.
  frosted,

  /// Refractive glass from `liquid_glass_easy`. On Skia without a
  /// `LiquidGlassView` the package itself falls back to a frosted look.
  liquid,
}

/// A glass surface: clipped backdrop blur, a translucent fill and a hairline
/// rim. Use it for bars, sheets and dialogs, not for list items (a blur per
/// row is expensive).
class MornyeGlass extends StatelessWidget {
  const MornyeGlass({
    super.key,
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.level = MornyeGlassLevel.frosted,
    this.fill,
    this.border,
    this.sigma = 24,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final MornyeGlassLevel level;

  /// Overrides the surface colour that is made translucent.
  final Color? fill;

  /// Overrides the rim (default: a hairline all around). Ignored when the
  /// style has outlines turned off.
  final BoxBorder? border;
  final double sigma;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final style = context.mornye;
    final base = fill ?? theme.colorScheme.surfaceContainerHigh;
    // Clearer glass lets more of the page through.
    final alpha = 0.92 - 0.42 * style.glassClarity;
    final rimColor = (dark ? Colors.white : Colors.white).withValues(
      alpha: dark ? 0.14 : 0.6,
    );
    final rim =
        border ??
        Border.fromBorderSide(BorderSide(width: 0.5, color: rimColor));

    // Like the system, drop the see-through effects when the user asks for
    // more contrast: a plain translucent fill stays readable.
    final level = MediaQuery.highContrastOf(context)
        ? MornyeGlassLevel.flat
        : this.level;
    if (level == MornyeGlassLevel.liquid) {
      return LiquidGlassLens(
        style: LiquidGlassStyle(
          shape: LiquidGlassShape.roundedRectangle(
            cornerRadius: borderRadius.topLeft.x,
          ),
          // Clarity spans the whole range: milky and well blurred at 0, almost
          // see-through and sharply refracting at 1.
          color: base.withValues(alpha: 0.8 - 0.7 * style.glassClarity),
          blur: 16 - 13 * style.glassClarity,
          // The lens draws its own rim; outlines off removes the highlight.
          specular: style.glassOutlines
              ? null
              : const LiquidGlassLight.specular(
                  intensity: 0,
                  oppositeIntensity: 0,
                ),
          refractionIndex: 1.01 + 0.03 * style.glassClarity,
          refractionWidth: 16,
        ),
        child: child,
      );
    }

    Widget surface = DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: style.glassOutlines ? rim : null,
      ),
      child: ColoredBox(
        color: base.withValues(alpha: alpha),
        child: child,
      ),
    );
    if (level != MornyeGlassLevel.flat) {
      surface = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: surface,
      );
    }
    return ClipRRect(borderRadius: borderRadius, child: surface);
  }
}
