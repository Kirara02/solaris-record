import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/settings/settings_providers.dart';
import '../theme/app_tokens.dart';
import '../theme/mornye_theme.dart';
import '../widgets/mornye_glass.dart';
import 'window_size.dart';

/// Like [showDialog], but centered over the content pane. On wide layouts the
/// navigation rail is reported as the left padding of the caller's
/// [MediaQuery]; dialogs live on the root navigator and would otherwise be
/// centered on the whole window.
Future<T?> showContentDialog<T>(BuildContext context, WidgetBuilder builder) {
  final inset = MediaQuery.paddingOf(context).left;
  return showDialog<T>(
    context: context,
    builder: (dialogContext) => Padding(
      padding: EdgeInsets.only(left: inset),
      child: builder(dialogContext),
    ),
  );
}

/// A picker or details panel: a bottom sheet on compact windows, a dialog
/// centered over the content pane on wider ones. A sheet would span the whole
/// window there, and its SafeArea would treat the navigation rail as a left
/// inset. [builder] returns the content only; scrolling and the safe area are
/// added here, and the given context is the one to `Navigator.pop`.
/// Content is laid out with 16px side margins, like the 5★ detail.
Future<void> showAdaptiveSheet(BuildContext context, WidgetBuilder builder) {
  if (context.windowSize == WindowSize.compact) {
    return showModalBottomSheet<void>(
      context: context,
      // Under Mornye the handle is drawn inside the glass panel.
      showDragHandle: !context.isMornye,
      isScrollControlled: true,
      // Tall content scrolls inside the sheet instead of filling the screen,
      // which would leave no scrim to tap and close it.
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      builder: (sheetContext) {
        final content = SafeArea(
          child: SingleChildScrollView(child: builder(sheetContext)),
        );
        if (!sheetContext.isMornye) return content;
        return MornyeGlass(
          level: _glassLevel(sheetContext),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(sheetContext.tokens.radiusSheet),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: Theme.of(sheetContext).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(child: content),
            ],
          ),
        );
      },
    );
  }
  return showContentDialog<void>(
    context,
    (dialogContext) => Dialog(
      backgroundColor: dialogContext.isMornye ? Colors.transparent : null,
      elevation: dialogContext.isMornye ? 0 : null,
      child: _maybeGlass(
        dialogContext,
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            // Adds to the content's own 16 so the dialog gets 24 on every side (the
            // sheet needs no top padding, its drag handle provides it).
            padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
            child: builder(dialogContext),
          ),
        ),
      ),
    ),
  );
}

Widget _maybeGlass(BuildContext context, Widget child) => context.isMornye
    ? MornyeGlass(
        level: _glassLevel(context),
        borderRadius: BorderRadius.circular(context.tokens.radiusSheet),
        child: child,
      )
    : child;

/// Sheets and dialogs are the one big glass surface on screen, so they get the
/// refractive glass unless blur is turned off in Appearance.
MornyeGlassLevel _glassLevel(BuildContext context) =>
    ProviderScope.containerOf(context).read(navBarBlurProvider)
    ? MornyeGlassLevel.liquid
    : MornyeGlassLevel.flat;
