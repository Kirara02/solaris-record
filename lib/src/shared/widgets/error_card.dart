import 'package:material_ui/material_ui.dart';

import '../theme/app_tokens.dart';
import '../theme/mornye_icons.dart';
import 'app_button.dart';

class ErrorCard extends StatelessWidget {
  const ErrorCard({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.retryLabel,
  });

  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = context.tokens;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(tokens.gapLg),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.6),
        borderRadius: tokens.borderRadiusCard,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdaptiveIcon(Icons.error_outline, color: scheme.error),
          SizedBox(width: tokens.gapMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: TextStyle(
                      color: scheme.onErrorContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: tokens.gapXs),
                ],
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: scheme.onErrorContainer),
                ),
                if (onRetry != null) ...[
                  SizedBox(height: tokens.gapMd),
                  AppButton(
                    style: AppButtonStyle.tonal,
                    icon: const AdaptiveIcon(Icons.refresh),
                    label: Text(retryLabel ?? ''),
                    onPressed: onRetry,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
