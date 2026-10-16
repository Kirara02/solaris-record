import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/stats/item_names.dart';

/// An item's name in the selected data language, falling back to the stored
/// English name [fallback] until (or unless) a translation is available.
class ItemName extends ConsumerWidget {
  const ItemName({
    super.key,
    required this.resourceId,
    required this.fallback,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  final int resourceId;
  final String fallback;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Text(
    ref.watch(itemNameResolverProvider)(resourceId, fallback),
    style: style,
    maxLines: maxLines,
    overflow: overflow,
    textAlign: textAlign,
  );
}
