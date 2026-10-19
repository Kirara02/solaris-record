import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:material_ui/material_ui.dart';

import 'mornye_theme.dart';

/// Cupertino counterparts of the Material icons the app uses. Icons without
/// an entry keep their Material glyph.
final _cupertinoFor = <IconData, IconData>{
  Icons.open_in_new: CupertinoIcons.arrow_up_right_square,
  Icons.close: CupertinoIcons.xmark,
  Icons.check_circle: CupertinoIcons.check_mark_circled_solid,
  Icons.check_circle_outline: CupertinoIcons.check_mark_circled,
  Icons.ios_share: CupertinoIcons.share,
  Icons.star: CupertinoIcons.star_fill,
  Icons.language: CupertinoIcons.globe,
  Icons.expand_more: CupertinoIcons.chevron_down,
  Icons.download_outlined: CupertinoIcons.arrow_down_to_line,
  Icons.download: CupertinoIcons.arrow_down_to_line,
  Icons.delete_outline: CupertinoIcons.trash,
  Icons.chevron_right: CupertinoIcons.chevron_right,
  Icons.chevron_left: CupertinoIcons.chevron_left,
  Icons.check: CupertinoIcons.check_mark,
  Icons.timeline: CupertinoIcons.graph_square,
  Icons.sync: CupertinoIcons.arrow_2_circlepath,
  Icons.autorenew: CupertinoIcons.arrow_2_squarepath,
  Icons.refresh: CupertinoIcons.refresh,
  Icons.storage_outlined: CupertinoIcons.archivebox,
  Icons.search: CupertinoIcons.search,
  Icons.pie_chart_outline: CupertinoIcons.chart_pie,
  Icons.donut_large: CupertinoIcons.chart_pie,
  Icons.people_outline: CupertinoIcons.person_2,
  Icons.person_outline: CupertinoIcons.person,
  Icons.manage_accounts_outlined: CupertinoIcons.person_crop_circle,
  Icons.layers_outlined: CupertinoIcons.layers_alt,
  Icons.insights: CupertinoIcons.graph_square_fill,
  Icons.insights_outlined: CupertinoIcons.graph_square,
  Icons.bar_chart: CupertinoIcons.chart_bar,
  Icons.info_outline: CupertinoIcons.info_circle,
  Icons.inbox_outlined: CupertinoIcons.tray,
  Icons.image_outlined: CupertinoIcons.photo,
  Icons.image_not_supported_outlined: CupertinoIcons.photo,
  Icons.wallpaper: CupertinoIcons.photo_on_rectangle,
  Icons.file_open_outlined: CupertinoIcons.folder,
  Icons.upload_file_outlined: CupertinoIcons.arrow_up_doc,
  Icons.description_outlined: CupertinoIcons.doc_text,
  Icons.article_outlined: CupertinoIcons.doc_plaintext,
  Icons.error_outline: CupertinoIcons.exclamationmark_circle,
  Icons.bug_report_outlined: CupertinoIcons.ant,
  Icons.zoom_out: CupertinoIcons.zoom_out,
  Icons.zoom_in: CupertinoIcons.zoom_in,
  Icons.visibility_off_outlined: CupertinoIcons.eye_slash,
  Icons.view_week_outlined: CupertinoIcons.rectangle_split_3x1,
  Icons.view_list: CupertinoIcons.list_bullet,
  Icons.grid_view: CupertinoIcons.square_grid_2x2,
  Icons.bubble_chart_outlined: CupertinoIcons.circle_grid_hex,
  Icons.tune: CupertinoIcons.slider_horizontal_3,
  Icons.translate: CupertinoIcons.textformat,
  Icons.g_translate: CupertinoIcons.textformat_alt,
  Icons.system_update: CupertinoIcons.arrow_down_circle,
  Icons.system_update_outlined: CupertinoIcons.arrow_down_circle,
  Icons.cloud_download_outlined: CupertinoIcons.cloud_download,
  Icons.settings_outlined: CupertinoIcons.gear,
  Icons.settings: CupertinoIcons.gear_solid,
  Icons.dashboard_outlined: CupertinoIcons.square_grid_2x2,
  Icons.dashboard: CupertinoIcons.square_grid_2x2_fill,
  Icons.home: CupertinoIcons.house_fill,
  Icons.schedule: CupertinoIcons.clock,
  Icons.radio_button_unchecked: CupertinoIcons.circle,
  Icons.phone_android: CupertinoIcons.device_phone_portrait,
  Icons.palette_outlined: CupertinoIcons.paintbrush,
  Icons.more_vert: CupertinoIcons.ellipsis_vertical,
  Icons.light_mode: CupertinoIcons.sun_max,
  Icons.light_mode_outlined: CupertinoIcons.sun_max,
  Icons.dark_mode: CupertinoIcons.moon,
  Icons.dark_mode_outlined: CupertinoIcons.moon,
  Icons.brightness_auto: CupertinoIcons.circle_lefthalf_fill,
  Icons.brightness_2: CupertinoIcons.moon_fill,
  Icons.blur_on: CupertinoIcons.drop,
  Icons.rounded_corner: CupertinoIcons.rectangle,
  Icons.first_page: CupertinoIcons.chevron_left_2,
  Icons.last_page: CupertinoIcons.chevron_right_2,
  Icons.gavel: CupertinoIcons.hammer,
  Icons.filter_alt_outlined: CupertinoIcons.line_horizontal_3_decrease,
  Icons.edit_outlined: CupertinoIcons.pencil,
  Icons.drag_handle: CupertinoIcons.line_horizontal_3,
  Icons.copy: CupertinoIcons.doc_on_doc,
  Icons.copy_all_outlined: CupertinoIcons.doc_on_doc,
  Icons.content_paste: CupertinoIcons.doc_on_clipboard,
  Icons.code: CupertinoIcons.chevron_left_slash_chevron_right,
  Icons.cleaning_services_outlined: CupertinoIcons.sparkles,
  Icons.auto_fix_high: CupertinoIcons.sparkles,
  Icons.auto_awesome: CupertinoIcons.sparkles,
  Icons.casino_outlined: CupertinoIcons.cube,
  Icons.campaign_outlined: CupertinoIcons.speaker_2,
  Icons.arrow_forward: CupertinoIcons.arrow_right,
  Icons.arrow_back: CupertinoIcons.chevron_back,
};

/// The Cupertino glyph for a Material [icon], or [icon] itself when there is
/// no counterpart.
IconData mornyeIconFor(IconData icon) => _cupertinoFor[icon] ?? icon;

extension AdaptiveIconContext on BuildContext {
  /// [icon] as the active style draws it: Cupertino under Mornye, otherwise
  /// unchanged.
  IconData adaptiveIcon(IconData icon) => isMornye ? mornyeIconFor(icon) : icon;
}

/// An [Icon] that swaps its Material glyph for the Cupertino one under the
/// Mornye style. Call sites keep using `Icons.*`.
class AdaptiveIcon extends StatelessWidget {
  const AdaptiveIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
  });

  final IconData? icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Icon(
    icon == null ? null : context.adaptiveIcon(icon!),
    size: size,
    color: color,
    semanticLabel: semanticLabel,
  );
}
