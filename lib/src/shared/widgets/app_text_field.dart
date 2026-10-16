import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_tokens.dart';

/// Rounded, borderless filled text field with a primary-coloured focus ring.
/// Colours are read from the resolved scheme at build time, so it follows the
/// dynamic palette.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefix,
    this.suffix,
    this.outlined = false,
    this.enabled = true,
    this.autofocus = false,
    this.minLines,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final Widget? prefix;
  final Widget? suffix;

  /// Thin outline on a transparent background (search / toolbar style)
  /// instead of the tonal filled look.
  final bool outlined;
  final bool enabled;
  final bool autofocus;
  final int? minLines;
  final int? maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(
      outlined ? 12 : context.tokens.radiusControl,
    );
    final idle = outlined
        ? BorderSide(color: scheme.outlineVariant)
        : BorderSide.none;
    OutlineInputBorder border(BorderSide side) =>
        OutlineInputBorder(borderRadius: radius, borderSide: side);

    return TextField(
      controller: controller,
      enabled: enabled,
      autofocus: autofocus,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      cursorColor: scheme.primary,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefix,
        suffixIcon: suffix,
        filled: !outlined,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
        floatingLabelStyle: TextStyle(color: scheme.primary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: border(idle),
        enabledBorder: border(idle),
        disabledBorder: border(idle),
        focusedBorder: border(BorderSide(color: scheme.primary, width: 2)),
        errorBorder: border(BorderSide(color: scheme.error)),
      ),
    );
  }
}
