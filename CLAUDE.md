# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Solaris Record: a cross-platform Flutter tracker for Wuthering Waves convene (gacha) history. Pity, pool statistics and multi-account (UID) support. Records are fetched from the Kuro API using a convene URL the user pastes in manually (no network interception, unlike the Windows-only reference project GoneTone/wuthering-waves-convene-gacha-analyzer).

## Reference projects

- Features: [GoneTone/wuthering-waves-convene-gacha-analyzer](https://github.com/GoneTone/wuthering-waves-convene-gacha-analyzer) (default branch is `master`). Use it as the guide for what the app should do (export/import JSON, WuWa Tracker import, quick update, banner types). Take the format and structure as inspiration; don't copy its code.
- Theming: [spotiflacapp/SpotiFLAC-Mobile](https://github.com/spotiflacapp/SpotiFLAC-Mobile). Use it as the guide for the strong Material 3 look (dynamic color, expressive surfaces and shapes).

## Commands

```bash
flutter pub get
dart run slang                      # regenerate translations; run after changing i18n JSON, and after cloning
dart run build_runner build         # regenerate riverpod, drift and flutter_gen code; run after changing providers, tables or assets, and after cloning (run slang first)
flutter analyze                     # the verification step for changes
flutter test                        # all tests in test/
flutter test test/features/stats/pity_calculator_test.dart               # one file
flutter test test/features/stats/pity_calculator_test.dart --plain-name "name"   # one test
flutter run -d macos                # or any other device
python3 tool/generate_app_icon.py   # regenerates icon art (needs Pillow); then apply with dart run flutter_launcher_icons
```

Tests mirror `lib/src/` (`test/data/`, `test/features/<feature>/`, `test/shared/`), with shared helpers in `test/support/` and JSON in `test/fixtures/`. The suite is deliberately small: core logic (pity, history sort and filter, URL parsing, repository merge, item info parsing, overview stats) plus a few key flows (import, delete data, navigation, i18n loading). Brittle layout and pixel tests were removed on purpose.

Project preferences from the maintainer: verify with `flutter analyze`, not `flutter build`; do not add new tests or throwaway render scripts unless asked (the maintainer mostly tests manually with `flutter run`).

## Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org/) in English: `type(scope): summary`, with the summary in the imperative and lower case, under about 72 characters, and a body that explains why when it is not obvious.

- Types: `feat`, `fix`, `docs`, `refactor`, `perf`, `test`, `build`, `ci`, `chore` (`chore(deps)` for dependency bumps).
- Scope is optional and usually a feature or area: `stats`, `import`, `backup`, `accounts`, `info`, `settings`, `i18n`, `theme`, `ci`, `release`.
- Examples: `feat(stats): add vertical 5★ timeline`, `fix(import): keep the saved link when the network drops`, `ci: generate code before building`.
- Run `flutter analyze` before committing. CI runs the tests.
- Pull requests are grouped on the release page by label (`enhancement`, `bug`, `documentation`, `dependencies`), and each release also needs its own section in `CHANGELOG.md` (see `docs/RELEASING.md`).

Lints that bite: `prefer_relative_imports` and `directives_ordering` (imports must be relative and sorted alphabetically within their sections).

## Architecture

Feature-first under `lib/src/`: `features/<name>/{domain,data,presentation}`, plus `data/` (persistence + the central provider wiring) and `shared/` (theme, i18n, routing, layout, widgets). State is Riverpod 3 with `riverpod_generator`: providers are `@riverpod` functions/classes in `*_providers.dart` files with a `part '*.g.dart'`.

Data flow for an import: `features/import/import_controller.dart` parses the URL (`domain/convene_url.dart`), calls `ConveneApi` once per `PoolType` (with a request gap), and hands each page to `ConveneRepository.mergeRecords`. Stats screens never fetch; they watch `recordsProvider(uid, pool)` (a drift stream) and `poolStatsProvider` derives pity/averages/50-50 through the pure functions in `features/stats/domain/pity_calculator.dart` and `overview_stats.dart`.

Things that need more than one file to understand:

- **Persistence and dedup** (`data/database.dart`, `data/convene_repository.dart`): drift/SQLite with two tables. The unique key `(uid, poolType, time, name, recordIndex)` is what makes merging safe; `recordIndex` is the position among records sharing one `time` (a 10-pull has one timestamp). Merging keeps existing rows, so history the server already dropped is never lost, and the API only returns a limited window, so local data is irreplaceable. Schema changes need a `schemaVersion` bump and an `onUpgrade` step (currently v2, which added `resourceId`).
- **Backup/import** (`features/backup/`): one JSON bundle (`schema_version`, `app: solaris_record`, accounts with their records) written by `ConveneRepository.exportBundle` and merged by `importBundle` (additive: never deletes or overwrites, only fills a missing alias, server id or resourceId). `parseBackup` auto-detects this app's backup or a WuWa Tracker export (`wuwa_tracker_import.dart`, UTC times shifted +8h to the server wall clock the API uses).
- **Central providers** (`data/providers.dart`): the database, repository, Dio clients and info services are `keepAlive` providers defined here; features depend on these rather than constructing them.
- **`PoolType`** (`features/stats/domain/pool_type.dart`): the enum ids are the Kuro `cardPoolType` values. Only the featured resonator banner has a 50/50 (`hasFiftyFifty`). The valid ids are 1–6 and 8–13 (New Voyage, Collab, Reverb added); 7 does not exist (a live response for it was empty), so there is no Gratitude pool. Verified against the live API: 1 featured resonator, 2 featured weapon, 10–12 return data, and the server answers any id with an empty list rather than an error. The response's own `cardPoolType` label is unreliable (a localized pool name for 1–4, e.g. type 2 is labelled "Resonators Accurate Modulation - 2" yet holds weapons), so never map pools from it. The import skips a non-first pool the server rejects, and `hardPity5` is per pool (50 for beginner, otherwise 80).
- **Debug log** (`shared/logging/`): `AppLog.init()` in `main()` routes every `package:logging` `Logger` to a daily file under the app support directory (7 days, 2 MB cap per file) plus an in-memory buffer (all there is on web); Data & storage exports and clears it. Log in English via `Logger('area')`, and never log a UID, convene URL or token without `sanitizeUid` / `sanitizeUrl`.
- **Updates** (`features/update/`): checks GitHub's `releases/latest` for `Kirara02/solaris-record` (the releases the tag workflow publishes, not raw tags), compares it with the installed version and shows `UpdateDialog` (at launch via `UpdateStartupCheck`, at most every 12 hours and switchable; manually from About). On Android the dialog downloads the APK for the device's CPU, verifies GitHub's SHA-256 and hands it to the system installer (`open_filex`); elsewhere the download opens in the browser. Which file is offered is decided by the release file names (`assetSuffixFor`), so they must keep their `…-android-arm64-v8a.apk`, `…-windows-x64.zip` style. Release notes shown in the dialog come from the release body, cut at its first `---`.
- **Data language** (`features/stats/item_names.dart`, `ItemName` widget): pulls are always fetched and stored in English (50/50 detection and merge depend on it). The user's data language only changes the name *shown*, looked up by `resourceId` in the encore.moe list endpoints (`ItemNameService`), falling back to the stored English name. Use `ItemName` (or `itemNameResolverProvider`) rather than `record.name` when displaying an item. The item info dialog uses the same language.
- **Item icons and info**: resolved at runtime from encore.moe (`features/stats/data/item_image_service.dart`, `features/info/`), cached on disk by `CachedNetworkImage` and in shared preferences. `ItemIcon` takes a resource id and type and looks the URL up through `itemImageUrlProvider`.
- **UI stack**: `material_ui` and `material_3_expressive` instead of plain Material (so routing uses widgets-level `NoTransitionPage`/`CustomTransitionPage`, see `shared/routing/app_router.dart`). Dynamic color with a seed fallback; shared scale in `shared/theme/app_tokens.dart` (read via `context.tokens`) and rarity colors in `app_colors.dart`.
- **Adaptive layout**: `shared/layout/window_size.dart` defines compact/medium/expanded. Compact uses a bottom nav, wider windows a rail (`features/shell/`). Screens are `CustomScrollView`s of slivers; wrap content slivers in `SliverAdaptivePadding` so side margins follow the window class. On wide layouts the pool selector lives in the rail, on phones it is a chip row in `StatsScreen`.
- **i18n**: slang with `en` (base) and `id`, sources in `lib/src/shared/i18n/*.i18n.json`, generated into `i18n/gen/`. Locales are eagerly loaded (`lazy: false`, see `slang.yaml`) because deferred loading crashed release builds on Indonesian devices. Add every new string to both JSON files, then run `dart run slang`. Translations use the slang CLI configured in `slang.yaml`, not `slang_build_runner`. Generated code (`*.g.dart`, `*.gen.dart`, `i18n/gen/`) is git-ignored and never committed; CI and the release workflow generate it in `.github/actions/flutter-setup`, which also pins the Flutter version.
