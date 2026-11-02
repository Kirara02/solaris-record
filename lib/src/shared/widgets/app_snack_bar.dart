import 'package:material_ui/material_ui.dart';

import '../theme/mornye_icons.dart';
import '../theme/mornye_theme.dart';
import 'mornye_glass.dart';

extension AppSnackBar on ScaffoldMessengerState {
  /// Shows [message]: a plain snack bar in Material, a floating glass panel
  /// in the Mornye style (like its dialogs, with less tint since a message has
  /// no scrim).
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showMessage(
    String message,
  ) {
    if (!context.isMornye) {
      return showSnackBar(SnackBar(content: Text(message)));
    }
    final theme = Theme.of(context);
    final glass = MediaQuery.disableAnimationsOf(context);
    return showSnackBar(
      _GlassSnackBar(
        reduceMotion: glass,
        content: MornyeGlass.overlay(
          borderRadius: BorderRadius.circular(24),
          tintOpacity: 0.48,
          level: MornyeGlassLevel.liquid,
          child: Material(
            type: MaterialType.transparency,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: MaterialLocalizations.of(context)
                        .closeButtonTooltip,
                    color: theme.colorScheme.onSurface,
                    onPressed: hideCurrentSnackBar,
                    icon: const AdaptiveIcon(Icons.close, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassSnackBar extends SnackBar {
  const _GlassSnackBar({required super.content, required this.reduceMotion})
    : super(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        clipBehavior: Clip.none,
        showCloseIcon: false,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      );

  final bool reduceMotion;

  @override
  SnackBar withAnimation(Animation<double> newAnimation, {Key? fallbackKey}) {
    // Keep the messenger's controller and timer for queuing and dismissal,
    // but replace Material's opacity layer with movement so the blur keeps
    // sampling the page.
    return SnackBar(
      key: key ?? fallbackKey,
      duration: duration,
      showCloseIcon: false,
      behavior: behavior,
      backgroundColor: backgroundColor,
      elevation: elevation,
      clipBehavior: clipBehavior,
      padding: padding,
      margin: margin,
      shape: shape,
      animation: const AlwaysStoppedAnimation(1),
      content: AnimatedBuilder(
        animation: newAnimation,
        child: content,
        builder: (context, child) => Transform.translate(
          offset: Offset(
            0,
            reduceMotion
                ? 0
                : 8 * (1 - Curves.easeOutCubic.transform(newAnimation.value)),
          ),
          child: child,
        ),
      ),
    );
  }
}
