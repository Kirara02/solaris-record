---
name: add-theme-aware-ui
description: Checklist for new UI in Solaris Record that must work in both Material and Mornye styles. Use when adding a screen, dialog, sheet, icon, card or any widget that uses colors, glass or icons.
---

# Theme-aware UI checklist

The app has two styles (`AppThemeStyle`): Material 3 and Mornye. New UI has to look right in both.

- **Icons**: use `AdaptiveIcon`. Register any new `Icons.*` in `lib/src/shared/theme/mornye_icons.dart` so Mornye gets a Cupertino glyph.
- **Dialogs**: `AppDialog` / `AppAlertDialog` (`lib/src/shared/widgets/app_dialog.dart`), or `showConfirmDialog` (`confirm_dialog.dart`) for yes/no. No raw `AlertDialog`.
- **Sheets**: `showAdaptiveSheet` (`lib/src/shared/layout/content_dialog.dart`).
- **Glass** (`MornyeGlass`, `lib/src/shared/widgets/mornye_glass.dart`): only for chrome that floats (tab bar, sidebar, sheets, dialogs). Cards stay solid.
- **Colors**: read the theme (`context.isMornye`, `context.mornye`) instead of hard-coding. In Mornye the container roles are neutral greys, so never use `primaryContainer` / `secondaryContainer` as a *data* colour (see `_Outcome` in `five_star_bubbles.dart`). Rarity colors live in `app_colors.dart`.
- **Scale**: spacing, radii and sizes from `context.tokens` (`shared/theme/app_tokens.dart`), not magic numbers.
- **Layout**: screens are `CustomScrollView`s of slivers; wrap content slivers in `SliverAdaptivePadding`. Check compact (bottom bar), medium and expanded (rail).
- **Item names** go through `ItemName` / `itemNameResolverProvider`, not `record.name`.
- **Strings** go through the `add-i18n-string` skill.
- Verify with `flutter analyze`; the maintainer checks the visuals manually in both styles with `flutter run`. Do not add render scripts or pixel tests.

Background: `CLAUDE.md` (Styles and UI stack entries).
