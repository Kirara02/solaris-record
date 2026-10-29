---
name: drift-migration
description: Change the drift/SQLite schema of Solaris Record (new column, table or index). Use when editing lib/src/data/database.dart tables, bumping schemaVersion, or writing an onUpgrade step.
---

# Drift schema migration

Local data is irreplaceable: the API only returns a limited window of history, so a bad migration loses records for good. Migrations must be additive.

1. Edit the table in `lib/src/data/database.dart`. Do not change the unique key `(uid, poolType, time, name, recordIndex)` on `ConveneRecords`; merge dedup depends on it.
2. Bump `schemaVersion` (read the current value in the file; it is not the number written in `CLAUDE.md`).
3. Add an `if (from < N)` block in `onUpgrade`, following the existing ones:
   - Guard `m.addColumn(...)` with `_hasColumn('<table>', '<snake_case_column>')` so the step can re-run safely.
   - Backfill existing rows with `customStatement` when a default is not enough (see `number` and `sort_order`).
   - Never drop or rewrite existing records.
4. `dart run build_runner build` to regenerate the drift code.
5. If the data is part of a backup, update `ConveneRepository.exportBundle` / `importBundle` (`lib/src/data/convene_repository.dart`) and `backup_bundle.dart`. Import stays additive: it never deletes or overwrites, only fills missing values. Bump `backupSchemaVersion` only if older builds could no longer read the new bundle.
6. `flutter analyze`. Do not add tests unless asked; the maintainer checks upgrades manually with `flutter run` on an existing database.

Background: `CLAUDE.md` (persistence and backup entries).
