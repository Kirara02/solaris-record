# Changelog

Release notes, newest first. Each release needs a section headed `## <version>`
(for example `## 1.0.1`) before its tag is pushed: the release workflow shows
that section on the GitHub release and fails if it is missing.

## 1.1.0

Solaris Record can now tell you when a new version is out and, on Android, install it for you.

### What's new
- Update checks: the app looks at the latest GitHub release when it opens (at most twice a day) and offers it in a dialog with the release notes. Switch it off, or check by hand, under *Settings → About → Updates*.
- On Android the update is downloaded in the app, checked against the release's SHA-256 and handed to the system installer. Android asks once to allow installs from Solaris Record. On Windows, macOS and Linux the download opens in your browser.
- You can skip a version and the app stops offering it until a newer one comes out.
- The pull detail sheet is taller, so the *Item info* button no longer hides in the scroll area.
- "1 pull" is no longer written "1 pulls".

### Updating from 1.0.0
Version 1.0.0 has no update check, so install this one by hand (download it from this page). From here on the app can update itself.

## 1.0.0

**Solaris Record** is an open-source convene (gacha) tracker for Wuthering Waves for Android, Windows, macOS and Linux. It keeps your pull history on your device and shows pity, 5★/4★ results, 50/50 and statistics across multiple accounts. This is the first public release.

### How it works
Open *Convene → Convene History* in the game, copy the page's URL, paste it into the app and tap **Update records**. Records are merged into your local database and never deleted, so older history survives even after the game stops returning it. The link expires after roughly 10 to 20 minutes.

### Tracking
- Multiple accounts by UID, with aliases (default "Account N") and an option to mask UIDs everywhere.
- All 12 convene types: Featured, Standard, Beginner, Beginner's Choice, New Voyage, Collab and Reverb, for Resonators and Weapons.
- Quick updates: the last working link is remembered per account.

### Analysis
- Pity for 5★ and 4★ with the pulls left until it is guaranteed, averages, and a 50/50 record for the featured Resonator banner.
- 5★ timelines per pull type and across all of them, colored by luck, horizontal or vertical.
- Overview with rarity and item type charts, 5★ per pull type, and the current pity of each pull type.
- History with search, rarity and type filters, multi-column sort, pull numbers and per-pull pity.

### Item info
- Details for Resonators and Weapons (skills, effects, base stats by level) with a gallery of icon, outfit and convene art that you can zoom and save.
- Data language: show item names in another language without changing your stored records.

### Data and privacy
- Everything stays on your device. JSON backup and restore, and import from a WuWa Tracker export (`wuwatracker-pulls.json`). Imports only add records and never overwrite existing ones.
- Exportable debug log with UIDs and links masked.

### Look and feel
- Material 3 with dynamic color, accent colors and an AMOLED dark mode. English and Indonesian.

### Known limitations
- The game only returns a limited window of recent history (roughly the last six months in testing), so export a backup now and then.
- Collab and Reverb pulls were checked against real data. The New Voyage and Reverb Weapon pull types are in the app but were empty on the account used for testing, so they are not verified, and neither is the Beginner pity limit of 50.
- The 50/50 record relies on a built-in list of the standard 5★ Resonators, so it needs an update when a new standard Resonator appears.
- encore.moe has no Indonesian item names yet, so that data language falls back to English.
- Windows and macOS builds are not code-signed. There is no iOS or web build.
