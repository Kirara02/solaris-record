import 'package:material_ui/material_ui.dart';

import '../../features/settings/settings_providers.dart';
import 'mornye_glass.dart';

/// One glass panel holding a whole popup menu, for [PopupMenuButton] under the
/// Mornye style. Return it as the only entry of `itemBuilder` and build the
/// rows from [GlassMenuItem] and [Divider]. The popup route's own surface is
/// transparent in that style (see `MornyeTheme`), so the glass is what shows.
class GlassMenu extends PopupMenuEntry<String> {
  const GlassMenu({super.key, required this.children});

  final List<Widget> children;

  @override
  double get height => 48;

  @override
  bool represents(String? value) => false;

  @override
  State<GlassMenu> createState() => _GlassMenuState();
}

class _GlassMenuState extends State<GlassMenu> {
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return MornyeGlass.overlay(
      level: glassLevelOf(context),
      borderRadius: BorderRadius.circular(28),
      smoothCorners: true,
      fill: dark ? const Color(0xff414141) : Colors.white,
      tintOpacity: 0.80,
      highlightBorder: true,
      highlightIntensity: 0.4,
      child: Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: widget.children,
          ),
        ),
      ),
    );
  }
}

/// A tappable row of a [GlassMenu]; tapping closes the menu with [value].
class GlassMenuItem extends StatelessWidget {
  const GlassMenuItem({super.key, required this.value, required this.child});

  final String value;
  final Widget child;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => Navigator.pop(context, value),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: child,
    ),
  );
}
