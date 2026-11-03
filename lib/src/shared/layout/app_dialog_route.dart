import 'package:flutter/cupertino.dart'
    show CupertinoDynamicColor, kCupertinoModalBarrierColor;
import 'package:material_ui/material_ui.dart';

import '../theme/mornye_theme.dart';

/// [showDialog] for the app. Under the Mornye style the dialog takes the iOS
/// scrim and a timed scale-in without a fade: a fading dialog is drawn into an
/// opacity layer that hides the page from the glass' backdrop filter, so the
/// glass would lose its blur for the length of the animation.
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  if (!context.isMornye) {
    return showDialog<T>(context: context, builder: builder);
  }
  final navigator = Navigator.of(context, rootNavigator: true);
  return navigator.push(
    _MornyeDialogRoute<T>(
      context: context,
      themes: InheritedTheme.capture(from: context, to: navigator.context),
      builder: builder,
    ),
  );
}

class _MornyeDialogRoute<T> extends RawDialogRoute<T> {
  _MornyeDialogRoute({
    required BuildContext context,
    required CapturedThemes themes,
    required WidgetBuilder builder,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) =>
             SafeArea(child: themes.wrap(Builder(builder: builder))),
         barrierDismissible: true,
         barrierColor: CupertinoDynamicColor.resolve(
           kCupertinoModalBarrierColor,
           context,
         ),
         barrierLabel: MaterialLocalizations.of(context)
             .modalBarrierDismissLabel,
         transitionDuration: MediaQuery.disableAnimationsOf(context)
             ? Duration.zero
             : const Duration(milliseconds: 220),
       );

  // A timed exit instead of a settling spring.
  @override
  Duration get reverseTransitionDuration => transitionDuration == Duration.zero
      ? Duration.zero
      : const Duration(milliseconds: 160);

  CurvedAnimation? _scale;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final scale = _scale ??= CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return ScaleTransition(
      scale: scale.drive(Tween<double>(begin: 0.96, end: 1)),
      child: child,
    );
  }

  @override
  void dispose() {
    _scale?.dispose();
    super.dispose();
  }
}
