# Changelog

Release notes, newest first. Each release needs a section headed `## <version>`
(for example `## 1.0.1`) before its tag is pushed: the release workflow shows
that section on the GitHub release and fails if it is missing.

## 1.4.0

A second look for the app, Mornye, and notifications while an update downloads on Android.

### What's new
- **Mornye style (Beta).** Pick it under *Appearance → Style*. It uses iOS-style grouped colors and icons, with glass for the tab bar, sidebar, sheets and dialogs. Choose an accent color, how clear the glass is, and whether glass surfaces get an outline. Material 3 stays the default and looks the same as before.
- **Update notifications on Android.** While an update downloads, a notification shows the progress and keeps the download going when the screen turns off. When it is done, a notification with a sound says the update is ready, and tapping it starts the installer. A failed download gets a notification too. Once the app has been updated the notification goes away by itself.

### Notes
- Android 13 and newer asks for permission to show notifications the first time you download an update. The update still installs if you say no.
- "Blurred navigation" also controls the glass in Mornye: turn it off on slower devices.
- The new translations were machine-made and have not been reviewed by native speakers.

## 1.3.2

Fixes importing a backup on some devices, and centers a few images and screens on wide layouts.

### Fixes
- Importing a backup could fail with "duplicate column name" when the database had already been upgraded. Database upgrades now skip columns that already exist.
- The "No account yet" screen is now centered in the area beside the side rail on desktop, not on the whole window.
- Weapon artwork is shifted toward the center in the item info dialog and on 5★ cards, instead of sitting at the right edge.

## 1.3.1

Fixes the Android release build crashing at startup.

### Fixes
- On Android, version 1.3.0 could crash right after launch and never show the app. Saved settings are read again as in 1.2.1.

## 1.3.0

You can share your pulls as an image, drag your accounts into the order you like, see 5★ pulls as artwork cards, and use the app in Japanese and Chinese.

### What's new
- **Share as an image.** The share button in the stats header makes a picture of the overview or of one pull type, with the totals, rarity and item type charts, a 5★ timeline and the list of your 5★. Pick a dark or light look, and choose whether the full UID is shown (it follows *Mask UID* until you change it). Phones open the share sheet; on desktop a save dialog opens in your Downloads folder.
- **Reorder accounts.** Drag the handle on an account in *Accounts* to change the order, also in the account switcher. Accounts without an alias keep their "Account N" name.
- **5★ cards.** The 5★ overview can show each pull as a card with the item's convene artwork and outfit behind its pull count, name and time. It is the default; switch back to bubbles with the button above the list.
- **More languages.** Japanese, Simplified Chinese and Traditional Chinese join English and Indonesian. Pick one under *Appearance → Language*.

### Fixes
- The language pickers and the account menus are now centered over the content on desktop, like the pull detail, instead of covering the whole window with an off-center list.

### Notes
- The new translations were machine-made and have not been reviewed by native speakers; the pull type names in particular may differ from the game's. Corrections are welcome as issues.

## 1.2.1

Dialogs on desktop now sit in the middle of the content, and the update dialog buttons have their labels back.

### Fixes
- On desktop, the pull detail and item info dialogs are centered over the content area instead of the whole window. The pull detail is a dialog on wider windows and stays a bottom sheet on phones.
- The horizontal 5★ timeline no longer starts with a wide empty gap on desktop.
- The Skip, Later and Cancel buttons in the update dialog showed no text.

## 1.2.0

Importing is easier to get into, the navigation is translucent, dynamic color follows your wallpaper more faithfully, and there is a log viewer for bug reports.

### What's new
- **Guides for getting your link.** The import dialog now has a guide per platform (Windows, Android, iOS, macOS, Linux) with the ways WuWa Tracker documents, including copyable commands for Windows, macOS and Linux. A second guide explains where to get a backup file or a WuWa Tracker export to import.
- **Fewer steps to import.** If a convene link is on your clipboard, the import dialog fills it in. On Android you can also share a link to Solaris Record from another app.
- **What's new after an update.** The first launch of a new version shows its release notes once. The app can also show short notices from the developer, for example when the game's API changes. Switch them off under *Settings → About*.
- **Log viewer.** *Settings → Data & storage → View logs* lists this session's log with search and a severity filter, and a *Detailed logging* switch records more for bug reports. *About* links to the issue tracker.
- **Look and feel.** The bottom bar and the sidebar are translucent with a blur (switch it off under *Appearance* on slower devices). Dynamic color now uses your wallpaper palette as it is, instead of one re-derived from a single color. Item info and the pull detail sheet take their accent color from the item's icon. Buttons, chips and switches share one style, and settings groups drop their animations when the system asks for less motion.
- **macOS disk image.** macOS downloads now come as a `.dmg` with a shortcut to Applications. The zip is still published.

### Fixes
- AMOLED mode now blackens the buttons and cards that were still grey.

### Notes for macOS
The app is not signed. Drag it to Applications, then run `xattr -dr com.apple.quarantine "/Applications/Solaris Record.app"`. On macOS 15 and later, right-click → *Open* no longer works; use *System Settings → Privacy & Security → Open Anyway*.

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
