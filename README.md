# Solaris Record

Open-source, cross-platform convene (gacha) tracker for Wuthering Waves. Track pity, 5★/4★ history, 50/50 results and statistics across multiple accounts. Local-first, Material 3 or the iOS-style Mornye look, built with Flutter.

> Unofficial fan project. It is not affiliated with or endorsed by Kuro Games. Wuthering Waves and its assets belong to Kuro Games.

## Screenshots

### Desktop

<table>
  <tr>
    <td width="50%"><img src="docs/images/desktop/1.png" alt="Overview of every pull type"><br><sub><b>Overview</b>: totals, rarity and type charts, 5★ per pull type.</sub></td>
    <td width="50%"><img src="docs/images/desktop/2.png" alt="Featured Resonator pity and 50/50"><br><sub><b>Featured Resonator</b>: pity and 50/50 record.</sub></td>
  </tr>
  <tr>
    <td width="50%"><img src="docs/images/desktop/3.png" alt="Featured Resonator 5★ timeline and history"><br><sub><b>Resonator timeline</b>: 5★ timeline, 5★ pulls and history.</sub></td>
    <td width="50%"><img src="docs/images/desktop/4.png" alt="Item info dialog with the image gallery"><br><sub><b>Item info</b>: details and an icon, outfit and convene art gallery.</sub></td>
  </tr>
  <tr>
    <td width="50%"><img src="docs/images/desktop/5.png" alt="Featured Weapon pity and stats"><br><sub><b>Featured Weapon</b>: pity and stats.</sub></td>
    <td width="50%"><img src="docs/images/desktop/6.png" alt="Featured Weapon 5★ timeline and history"><br><sub><b>Weapon timeline</b>: timeline colored by luck, 5★ pulls and history.</sub></td>
  </tr>
  <tr>
    <td width="50%"><img src="docs/images/desktop/7.png" alt="Share as an image"><br><sub><b>Share image</b>: a picture of the overview or one pull type, dark or light.</sub></td>
    <td width="50%"><img src="docs/images/desktop/8.png" alt="Settings"><br><sub><b>Settings</b>: import, accounts, appearance, data and about.</sub></td>
  </tr>
</table>

### Mobile

<table>
  <tr>
    <td width="25%" align="center"><img src="docs/images/mobile/1.jpg" alt="Overview of every pull type"><br><sub><b>Overview</b></sub></td>
    <td width="25%" align="center"><img src="docs/images/mobile/2.jpg" alt="Type distribution and 5★ per pull type"><br><sub><b>5★ per pull type</b></sub></td>
    <td width="25%" align="center"><img src="docs/images/mobile/3.jpg" alt="Featured Resonator pity, stats and 50/50"><br><sub><b>Pity</b> and 50/50</sub></td>
    <td width="25%" align="center"><img src="docs/images/mobile/4.jpg" alt="5★ timeline, 5★ pulls and history"><br><sub><b>Timeline</b> and history</sub></td>
  </tr>
  <tr>
    <td width="25%" align="center"><img src="docs/images/mobile/5.jpg" alt="Featured Weapon pity and stats"><br><sub><b>Featured Weapon</b></sub></td>
    <td width="25%" align="center"><img src="docs/images/mobile/6.jpg" alt="Featured Weapon timeline and history"><br><sub><b>Weapon timeline</b></sub></td>
    <td width="25%" align="center"><img src="docs/images/mobile/7.jpg" alt="Item info with the image gallery"><br><sub><b>Item info</b></sub></td>
    <td width="25%" align="center"><img src="docs/images/mobile/8.jpg" alt="Share as an image"><br><sub><b>Share image</b></sub></td>
  </tr>
  <tr>
    <td width="25%" align="center"><img src="docs/images/mobile/9.jpg" alt="Settings"><br><sub><b>Settings</b></sub></td>
  </tr>
</table>

## Features

- **Multiple accounts** by UID, with aliases (default "Account N") and an option to mask UIDs everywhere.
- **All 12 convene types**: Featured, Standard, Beginner, Beginner's Choice, New Voyage, Collab and Reverb, for Resonators and Weapons.
- **Pity** for 5★ and 4★ with the pulls left until it is guaranteed, averages, and a **50/50** record for the featured Resonator banner.
- **Timelines** of every 5★, per pull type and across all of them, colored by luck, horizontal or vertical.
- **Overview** with rarity and item type charts, 5★ per pull type, and the current pity of each pull type.
- **History** with search, rarity and type filters, sort by time, name, type, rarity or pity, pull numbers and per-pull pity.
- **Explore** tab with a **Guide** (every Resonator, Weapon and Echo with search, filters and a detail screen) and **Redeem Code** (a list the maintainer keeps in `redeem-codes.json`, with a copy button).
- **Item info** for Resonators and Weapons (skills, effects, base stats by level) with an image gallery (icon, outfit, convene art).
- **Share as an image**: a picture of the overview or one pull type, dark or light, shared or saved. With an option to show the full UID.
- **Data language**: show item names in another language without touching your stored records.
- **Updates**: the app tells you when a new release is out and, on Android, installs it from inside the app, with a notification for the download's progress and when it is ready.
- **Backup**: export and import everything as JSON, and import a [WuWa Tracker](https://wuwatracker.com/) export.
- **Quick updates**: the last working link is remembered per account.
- **Import help**: per-platform guides for finding the link, clipboard prefill, and on Android import by sharing a convene link from another app.
- **What's new** after an update, plus occasional developer announcements.
- **Accounts** can be reordered by dragging.
- **5★ views**: card or bubble layout.
- **Translucent navigation** (and Mornye's glass) can be toggled in Settings.
- **Settings → Data**: log viewer, storage usage, clear cache and delete all data.
- **Two styles**: Material 3 with dynamic color, accent colors and an AMOLED dark mode, or **Mornye** (beta), an iOS-style look with glass bars, sheets and dialogs, a choice of accent color and adjustable glass clarity. English, Indonesian, Japanese and Simplified and Traditional Chinese.
- **Debug log** you can export when reporting a bug. UIDs are partly masked and links are masked in it.

## Downloads and platforms

Releases on GitHub include:

- **Android**: an APK per ABI; the app can download and install updates itself.
- **Windows**: zip. **Linux**: tar.gz. **macOS**: dmg (zip too).
- `SHA256SUMS.txt` to verify downloads.

Windows and macOS builds are unsigned. iOS and web are not published (see [docs/RELEASING.md](docs/RELEASING.md)). On non-Android platforms, an update opens the download in your browser.

## How it gets your records

The game keeps your convene history on Kuro's servers and shows it on the in-game *Convene History* page. Solaris Record asks the same service for it with the link of that page, which you copy and paste into the app. It does not intercept network traffic and never touches the game itself.

1. Open *Convene → Convene History* in Wuthering Waves and let the page load.
2. Copy the page's URL. It contains `svr_id`, `player_id` and `record_id`.
3. Paste it into **Import** in the app and tap **Update records**.

The link expires after a short while. The game only keeps a limited history, so Solaris Record merges what it fetches into your local data and never deletes older records. Export a backup now and then.

## Privacy

- Everything stays on your device: records live in a local SQLite database.
- The app only talks to Kuro's convene record service (to fetch your records), to [encore.moe](https://encore.moe/) and Kuro's guide server (for item names, icons and info), and to GitHub (`api.github.com` for update checks, `raw.githubusercontent.com` for `announcements.json` and `redeem-codes.json`). Announcements can be switched off in Settings → About.
- On Android, the app can show notifications about an update's download. They are local; nothing is sent anywhere.
- The link you paste carries an access token for your history, so the app keeps it only until the server rejects it or you delete the account, and never writes it to the debug log. **Delete all data** in Settings → Data also removes saved links.

## Build from source

You need [Flutter](https://docs.flutter.dev/get-started/install) 3.47.x (pinned in `.github/actions/flutter-setup`, Dart `^3.13.5`).

```bash
flutter pub get
dart run slang                   # translations
dart run build_runner build      # providers, database, assets
flutter run
```

Generated code (`*.g.dart`, `*.gen.dart`) is not committed, so run the two generators after cloning and again after changing providers, database tables, assets or translation files. Run `slang` first.

Useful commands:

```bash
flutter analyze   # lints, must stay clean
flutter test
```

The code is organised by feature under `lib/src/features/`; see [CLAUDE.md](CLAUDE.md) for an architecture overview, including how persistence, merging and the data language work.

## Contributing

Issues and pull requests are welcome. Please run `flutter analyze` before sending a change, and add new strings to every language file in `lib/src/shared/i18n/` (`en`, `id`, `ja`, `zh-Hans`, `zh-Hant`).

## Acknowledgements

- Feature ideas from [WuWa Analyzer](https://github.com/GoneTone/wuthering-waves-convene-gacha-analyzer) (MIT) by GoneTone.
- Theming inspiration from [SpotiFLAC-Mobile](https://github.com/spotiflacapp/SpotiFLAC-Mobile).
- Item data and images from [encore.moe](https://encore.moe/) and Kuro's guide server, loaded at runtime and not bundled with the app.
- [Inter](https://github.com/rsms/inter) typeface (SIL Open Font License).

## License

[MIT](LICENSE) © 2026 Kirara02
