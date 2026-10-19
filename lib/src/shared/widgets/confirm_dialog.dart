import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/settings/settings_providers.dart';

import '../theme/app_tokens.dart';
import '../theme/mornye_theme.dart';
import 'mornye_glass.dart';

/// Confirmation dialog with plain primary-coloured text buttons. Resolves to
/// `true` only when the user confirms (dismissing counts as cancel).
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  required String cancelLabel,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => context.isMornye
        ? _MornyeAlert(
            title: title,
            body: body,
            confirmLabel: confirmLabel,
            cancelLabel: cancelLabel,
          )
        : AlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(cancelLabel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(confirmLabel),
              ),
            ],
          ),
  );
  return confirmed ?? false;
}

/// iOS-style alert: a small glass panel with a centred title and message and
/// a row of buttons under a hairline.
class _MornyeAlert extends StatelessWidget {
  const _MornyeAlert({
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.cancelLabel,
  });

  final String title;
  final String body;
  final String confirmLabel;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    Widget button(String label, bool result, {bool bold = false}) => Expanded(
      child: TextButton(
        onPressed: () => Navigator.pop(context, result),
        style: TextButton.styleFrom(
          shape: const RoundedRectangleBorder(),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            fontSize: 17,
          ),
        ),
      ),
    );
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: MornyeGlass(
          level: ProviderScope.containerOf(context).read(navBarBlurProvider)
              ? MornyeGlassLevel.liquid
              : MornyeGlassLevel.flat,
          borderRadius: BorderRadius.circular(context.tokens.radiusCard + 6),
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        body,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Divider(color: scheme.outlineVariant),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      button(cancelLabel, false),
                      VerticalDivider(color: scheme.outlineVariant),
                      button(confirmLabel, true, bold: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
