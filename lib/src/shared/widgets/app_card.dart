import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_tokens.dart';
import '../theme/mornye_theme.dart';

/// Filled tonal card used for every content surface.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.color,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    if (context.isMornye) {
      return Container(
        width: double.infinity,
        padding: padding,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: color ?? Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: context.tokens.borderRadiusCard,
        ),
        child: Material(type: MaterialType.transparency, child: child),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: M3ECard(
        variant: M3ECardVariant.filled,
        color: color ?? Theme.of(context).colorScheme.surfaceContainerHigh,
        padding: padding,
        borderRadius: BorderRadius.circular(28),
        // ListTile and friends need a Material ancestor for ink.
        child: Material(type: MaterialType.transparency, child: child),
      ),
    );
  }
}
