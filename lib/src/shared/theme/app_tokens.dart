import 'package:material_ui/material_ui.dart';

/// Single source of truth for the app's visual scale (radii, gaps, row metrics,
/// header sizes). Read through [AppTokensContext.tokens] so widgets rendered
/// outside a themed subtree (tests) still get [AppTokens.standard].
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens();

  static const standard = AppTokens();

  final double radiusBadge = 6;
  final double radiusThumb = 8;
  final double radiusCover = 12;
  final double radiusControl = 16;
  final double radiusCard = 20;
  final double radiusSheet = 28;

  final double gapXs = 4;
  final double gapSm = 8;
  final double gapMd = 12;
  final double gapLg = 16;
  final double gapXl = 24;

  final double rowPaddingH = 20;
  final double rowPaddingV = 16;
  final double rowIconGap = 16;
  final double rowIconDividerIndent = 56;

  final double headerExpandedHeight = 88;
  final double headerCollapsedTitleSize = 20;
  final double headerExpandedTitleSize = 28;

  final Duration motionFast = const Duration(milliseconds: 150);
  final Duration motionMedium = const Duration(milliseconds: 250);

  BorderRadius get borderRadiusCard => BorderRadius.circular(radiusCard);
  BorderRadius get borderRadiusControl => BorderRadius.circular(radiusControl);

  @override
  AppTokens copyWith() => this;

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) => this;
}

extension AppTokensContext on BuildContext {
  AppTokens get tokens =>
      Theme.of(this).extension<AppTokens>() ?? AppTokens.standard;
}
