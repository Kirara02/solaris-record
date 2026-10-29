import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/mornye_theme.dart';

/// Indeterminate loading mark in the current style: the expressive morphing
/// indicator, or the iOS activity spinner under Mornye.
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) => context.isMornye
      ? const CupertinoActivityIndicator(radius: 14)
      : const M3ELoadingIndicator();
}
