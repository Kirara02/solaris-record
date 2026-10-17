import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../layout/window_size.dart';
import '../theme/app_tokens.dart';

/// Header for every screen.
///
/// Phone root screens get a large title that shrinks as the list scrolls;
/// tablet and desktop root screens get a regular pinned top bar. Screens with
/// [showBack] always get a pinned bar with the back arrow and the title on the
/// same line.
class AppSliverHeader extends StatelessWidget {
  const AppSliverHeader({
    super.key,
    required this.title,
    this.actions,
    this.showBack = false,
  });

  final String title;
  final List<Widget>? actions;
  final bool showBack;

  /// From this width a root screen gets a regular top bar instead of the
  /// large collapsing title (phones keep the large title).
  static const double topBarBreakpoint = 600;

  @override
  Widget build(BuildContext context) => SliverLayoutBuilder(
    builder: (context, constraints) {
      if (showBack) return _buildBackBar(context);
      return constraints.crossAxisExtent >= topBarBreakpoint
          ? _buildTopBar(context, constraints.crossAxisExtent)
          : _buildLargeTitle(context);
    },
  );

  /// Wide layouts: a fixed-height pinned bar with the title aligned to the
  /// content column and the actions at the end.
  Widget _buildTopBar(BuildContext context, double width) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    // The app bar's own safe area already keeps its content clear of a rail
    // the page extends under; only the size class needs the width left of it.
    final inset = WindowSize.sideInset(
      width - MediaQuery.paddingOf(context).left,
    );
    return SliverAppBar(
      pinned: true,
      toolbarHeight: 72,
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      centerTitle: false,
      titleSpacing: inset + 8,
      actionsPadding: EdgeInsets.only(right: inset),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: tokens.headerExpandedTitleSize - 2,
          fontWeight: FontWeight.bold,
          color: scheme.onSurface,
        ),
      ),
      actions: actions,
    );
  }

  Widget _buildBackBar(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    return SliverAppBar(
      pinned: true,
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      centerTitle: false,
      titleSpacing: 0,
      leading: IconButton(
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: tokens.headerExpandedTitleSize - 4,
          fontWeight: FontWeight.bold,
          color: scheme.onSurface,
        ),
      ),
      actions: actions,
    );
  }

  Widget _buildLargeTitle(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    // SliverAppBar adds the top safe-area inset to this itself, so adding
    // MediaQuery's padding here would double it on phones with a notch.
    final maxHeight = tokens.headerExpandedHeight;

    return SliverAppBar(
      expandedHeight: maxHeight,
      collapsedHeight: kToolbarHeight,
      pinned: true,
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      actions: actions,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          // Read the resolved sliver geometry so the collapse ratio stays
          // correct on devices with a top safe-area inset.
          final settings = context
              .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
          final minExtent = settings?.minExtent ?? kToolbarHeight;
          final maxExtent = settings?.maxExtent ?? maxHeight;
          final current = settings?.currentExtent ?? constraints.maxHeight;
          final delta = maxExtent - minExtent;
          final expand = delta > 0
              ? ((current - minExtent) / delta).clamp(0.0, 1.0)
              : 0.0;
          final fontSize =
              tokens.headerCollapsedTitleSize +
              (tokens.headerExpandedTitleSize -
                      tokens.headerCollapsedTitleSize) *
                  expand;

          return FlexibleSpaceBar(
            centerTitle: false,
            expandedTitleScale: 1.0,
            titlePadding: EdgeInsets.only(
              // Align with the content column's left edge (margin + 8).
              left: WindowSize.sideInset(constraints.maxWidth) + 8,
              right: tokens.gapLg,
              bottom: tokens.gapLg,
            ),
            title: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
          );
        },
      ),
    );
  }
}
