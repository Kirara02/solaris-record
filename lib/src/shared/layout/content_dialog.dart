import 'package:material_ui/material_ui.dart';

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
