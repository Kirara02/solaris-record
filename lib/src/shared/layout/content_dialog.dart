import 'package:material_ui/material_ui.dart';

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
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) =>
          SafeArea(child: SingleChildScrollView(child: builder(sheetContext))),
    );
  }
  return showContentDialog<void>(
    context,
    (dialogContext) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          // Adds to the content's own 16 so the dialog gets 24 on every side (the
          // sheet needs no top padding, its drag handle provides it).
          padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
          child: builder(dialogContext),
        ),
      ),
    ),
  );
}
