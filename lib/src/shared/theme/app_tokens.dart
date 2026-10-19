import 'package:material_ui/material_ui.dart';

/// Single source of truth for the app's visual scale (radii, gaps, row metrics,
/// header sizes). Read through [AppTokensContext.tokens] so widgets rendered
/// outside a themed subtree (tests) still get [AppTokens.standard].
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    this.radiusBadge = 6,
    this.radiusThumb = 8,
    this.radiusCover = 12,
    this.radiusControl = 16,
    this.radiusCard = 20,
    this.radiusSheet = 28,
    this.gapXs = 4,
    this.gapSm = 8,
    this.gapMd = 12,
    this.gapLg = 16,
    this.gapXl = 24,
    this.rowPaddingH = 20,
    this.rowPaddingV = 16,
    this.rowIconGap = 16,
    this.rowIconDividerIndent = 56,
    this.headerExpandedHeight = 88,
    this.headerCollapsedTitleSize = 20,
    this.headerExpandedTitleSize = 28,
    this.motionFast = const Duration(milliseconds: 150),
    this.motionMedium = const Duration(milliseconds: 250),
  });

  static const standard = AppTokens();

  final double radiusBadge;
  final double radiusThumb;
  final double radiusCover;
  final double radiusControl;
  final double radiusCard;
  final double radiusSheet;

  final double gapXs;
  final double gapSm;
  final double gapMd;
  final double gapLg;
  final double gapXl;

  final double rowPaddingH;
  final double rowPaddingV;
  final double rowIconGap;
  final double rowIconDividerIndent;

  final double headerExpandedHeight;
  final double headerCollapsedTitleSize;
  final double headerExpandedTitleSize;

  final Duration motionFast;
  final Duration motionMedium;

  BorderRadius get borderRadiusCard => BorderRadius.circular(radiusCard);
  BorderRadius get borderRadiusControl => BorderRadius.circular(radiusControl);

  @override
  AppTokens copyWith({
    double? radiusBadge,
    double? radiusThumb,
    double? radiusCover,
    double? radiusControl,
    double? radiusCard,
    double? radiusSheet,
    double? gapXs,
    double? gapSm,
    double? gapMd,
    double? gapLg,
    double? gapXl,
    double? rowPaddingH,
    double? rowPaddingV,
    double? rowIconGap,
    double? rowIconDividerIndent,
    double? headerExpandedHeight,
    double? headerCollapsedTitleSize,
    double? headerExpandedTitleSize,
    Duration? motionFast,
    Duration? motionMedium,
  }) => AppTokens(
    radiusBadge: radiusBadge ?? this.radiusBadge,
    radiusThumb: radiusThumb ?? this.radiusThumb,
    radiusCover: radiusCover ?? this.radiusCover,
    radiusControl: radiusControl ?? this.radiusControl,
    radiusCard: radiusCard ?? this.radiusCard,
    radiusSheet: radiusSheet ?? this.radiusSheet,
    gapXs: gapXs ?? this.gapXs,
    gapSm: gapSm ?? this.gapSm,
    gapMd: gapMd ?? this.gapMd,
    gapLg: gapLg ?? this.gapLg,
    gapXl: gapXl ?? this.gapXl,
    rowPaddingH: rowPaddingH ?? this.rowPaddingH,
    rowPaddingV: rowPaddingV ?? this.rowPaddingV,
    rowIconGap: rowIconGap ?? this.rowIconGap,
    rowIconDividerIndent: rowIconDividerIndent ?? this.rowIconDividerIndent,
    headerExpandedHeight: headerExpandedHeight ?? this.headerExpandedHeight,
    headerCollapsedTitleSize:
        headerCollapsedTitleSize ?? this.headerCollapsedTitleSize,
    headerExpandedTitleSize:
        headerExpandedTitleSize ?? this.headerExpandedTitleSize,
    motionFast: motionFast ?? this.motionFast,
    motionMedium: motionMedium ?? this.motionMedium,
  );

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    double d(double a, double b) => a + (b - a) * t;
    Duration m(Duration a, Duration b) => Duration(
      microseconds: d(
        a.inMicroseconds.toDouble(),
        b.inMicroseconds.toDouble(),
      ).round(),
    );
    return AppTokens(
      radiusBadge: d(radiusBadge, other.radiusBadge),
      radiusThumb: d(radiusThumb, other.radiusThumb),
      radiusCover: d(radiusCover, other.radiusCover),
      radiusControl: d(radiusControl, other.radiusControl),
      radiusCard: d(radiusCard, other.radiusCard),
      radiusSheet: d(radiusSheet, other.radiusSheet),
      gapXs: d(gapXs, other.gapXs),
      gapSm: d(gapSm, other.gapSm),
      gapMd: d(gapMd, other.gapMd),
      gapLg: d(gapLg, other.gapLg),
      gapXl: d(gapXl, other.gapXl),
      rowPaddingH: d(rowPaddingH, other.rowPaddingH),
      rowPaddingV: d(rowPaddingV, other.rowPaddingV),
      rowIconGap: d(rowIconGap, other.rowIconGap),
      rowIconDividerIndent: d(rowIconDividerIndent, other.rowIconDividerIndent),
      headerExpandedHeight: d(headerExpandedHeight, other.headerExpandedHeight),
      headerCollapsedTitleSize: d(
        headerCollapsedTitleSize,
        other.headerCollapsedTitleSize,
      ),
      headerExpandedTitleSize: d(
        headerExpandedTitleSize,
        other.headerExpandedTitleSize,
      ),
      motionFast: m(motionFast, other.motionFast),
      motionMedium: m(motionMedium, other.motionMedium),
    );
  }
}

extension AppTokensContext on BuildContext {
  AppTokens get tokens =>
      Theme.of(this).extension<AppTokens>() ?? AppTokens.standard;
}
