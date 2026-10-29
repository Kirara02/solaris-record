---
name: add-pool-type
description: Add a new convene pool (PoolType) to Solaris Record. Use when the game adds a banner type, or when touching PoolType ids, pity limits or pool labels.
---

# Add a pool type

Most screens iterate `PoolType.values` (rail, chip row, import progress, overview stats, WuWa Tracker import filter), so a new enum value shows up there on its own. The explicit touch points:

1. **Verify the id against the live API first.** The server answers *any* id with an empty list instead of an error, so an empty response proves nothing about validity. Valid ids today: 1-6 and 8-13 (7 does not exist). Never map a pool from the response's own `cardPoolType` label; it is unreliable (type 2 is labelled as a resonator pool yet holds weapons).
2. **Enum**: `lib/src/features/stats/domain/pool_type.dart`. Add the value with its Kuro id. Keep the order meaningful: it drives the rail, the chips and `import_controller.dart`, which treats `PoolType.values.first` specially (a non-first pool the server rejects is skipped). Do not reorder existing values.
3. **Rules in the same file**: `hardPity5` (80, except beginner at 50) and `hasFiftyFifty` (only the featured resonator banner). Change them only if the new pool really differs.
4. **Label**: add a case to the exhaustive switch in `lib/src/shared/i18n/pool_labels.dart` and a `pools.<name>` string through the `add-i18n-string` skill (all five languages).
5. **Check by eye** that these still behave with one more entry: `wide_shell.dart` (rail indexes are computed from `PoolType.values.length`), `stats_screen.dart` chip row, `import_dialog.dart` pool list.
6. Stored records need no migration: `poolType` is an int column, and backups and the WuWa Tracker import accept any id found in `PoolType.values`.
7. `flutter analyze`. Do not add tests unless asked.

Background: `CLAUDE.md` (`PoolType` entry).
