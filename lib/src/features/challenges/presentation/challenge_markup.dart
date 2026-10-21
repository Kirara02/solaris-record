import 'package:material_ui/material_ui.dart';

/// Game text with encore.moe's markup: `<br>` is a line break, and
/// `<span style="color:#rrggbb">` colours a run (keywords such as a state
/// name); `class="font-bold"` or `font-weight:bold` makes it bold. Other tags
/// are ignored.
class MarkupText extends StatelessWidget {
  const MarkupText(this.raw, {super.key, this.style});

  final String raw;
  final TextStyle? style;

  static final _token = RegExp(
    r'<br\s*/?>|<span\b([^>]*)>|</span>|<[^>]+>',
    caseSensitive: false,
  );
  static final _color = RegExp(r'color:\s*#([0-9a-fA-F]{6})');
  static final _bold = RegExp(r'font-bold|font-weight:\s*(bold|[6-9]00)');

  /// The runs of [raw] on top of [base].
  static List<InlineSpan> spans(String raw, TextStyle? base) {
    final out = <InlineSpan>[];
    final styles = <(Color?, bool)>[];
    var at = 0;
    void text(String s) {
      if (s.isEmpty) return;
      final color = styles.map((e) => e.$1).nonNulls.lastOrNull;
      final bold = styles.any((e) => e.$2);
      out.add(
        TextSpan(
          text: s.replaceAll('&nbsp;', ' ').replaceAll('&amp;', '&'),
          style: color == null && !bold
              ? null
              : TextStyle(
                  color: color,
                  fontWeight: bold ? FontWeight.w700 : null,
                ),
        ),
      );
    }

    for (final m in _token.allMatches(raw)) {
      text(raw.substring(at, m.start));
      at = m.end;
      final tag = m.group(0)!.toLowerCase();
      if (tag.startsWith('<br')) {
        out.add(const TextSpan(text: '\n'));
      } else if (tag.startsWith('<span')) {
        final attrs = m.group(1) ?? '';
        final hex = _color.firstMatch(attrs)?.group(1);
        styles.add((
          hex == null ? null : Color(0xFF000000 | int.parse(hex, radix: 16)),
          _bold.hasMatch(attrs.toLowerCase()),
        ));
      } else if (tag == '</span>' && styles.isNotEmpty) {
        styles.removeLast();
      }
    }
    text(raw.substring(at));
    return out;
  }

  @override
  Widget build(BuildContext context) =>
      Text.rich(TextSpan(style: style, children: spans(raw.trim(), style)));
}
