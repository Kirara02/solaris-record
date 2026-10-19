import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/settings/settings_providers.dart';
import '../theme/app_tokens.dart';
import '../theme/mornye_theme.dart';
import 'mornye_glass.dart';

/// [Dialog] that becomes a liquid-glass panel under the Mornye style.
class AppDialog extends StatelessWidget {
  const AppDialog({super.key, this.insetPadding, required this.child});

  final EdgeInsets? insetPadding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!context.isMornye) {
      return Dialog(
        insetPadding:
            insetPadding ??
            const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: child,
      );
    }
    final blur = ProviderScope.containerOf(context).read(navBarBlurProvider);
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding:
          insetPadding ??
          const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: MornyeGlass(
        level: blur ? MornyeGlassLevel.liquid : MornyeGlassLevel.flat,
        borderRadius: BorderRadius.circular(context.tokens.radiusSheet),
        // Ink in the content needs a Material above it.
        child: Material(type: MaterialType.transparency, child: child),
      ),
    );
  }
}

/// [AlertDialog] that becomes a liquid-glass panel under the Mornye style.
/// Only the parts the app uses are supported.
class AppAlertDialog extends StatelessWidget {
  const AppAlertDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.scrollable = false,
  });

  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    if (!context.isMornye) {
      return AlertDialog(
        title: title,
        content: content,
        actions: actions,
        scrollable: scrollable,
      );
    }
    final theme = Theme.of(context);
    Widget? body = content;
    if (body != null && scrollable) body = SingleChildScrollView(child: body);
    return AppDialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                DefaultTextStyle(
                  style: theme.textTheme.titleLarge!.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  child: title!,
                ),
              if (body != null) ...[
                const SizedBox(height: 12),
                Flexible(
                  child: DefaultTextStyle(
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    child: body,
                  ),
                ),
              ],
              if (actions != null && actions!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(spacing: 8, children: actions!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
