---
name: update-remote-json
description: Publish a redeem code or a developer announcement for Solaris Record. Use when adding, expiring or retiring a redeem code, or posting an announcement to users.
---

# Update redeem codes or announcements

Both files live at the repo root and are read by the app from the `main` branch, so a push to `dev` changes nothing for users. No app release is needed. Nothing about the user is sent.

## Redeem code (`redeem-codes.json`, format in `docs/REDEEM_CODES.md`)
- `code` is required; duplicates are compared ignoring case and skipped.
- `rewards` / `source`: a string or a map by language code (`en` is the fallback).
- `added` / `expires` are `YYYY-MM-DD`; a code works through its whole `expires` day.
- To retire a code early, set `"active": false` rather than deleting it (it moves to the Expired list).

## Announcement (`announcements.json`, format in `docs/ANNOUNCEMENTS.md`)
- `id`, `title`, `body` are required; text is a string or a language map.
- A dismissed `id` is never shown again, so a changed notice needs a **new** `id`.
- `ctaUrl` must be `https`, otherwise the button is dropped.
- Optional: `minVersion` / `maxVersion` (inclusive), `platforms`, `expires` (ISO timestamp).

## Steps
1. Edit the file; keep it valid JSON (check with `python3 -m json.tool <file>`).
2. Commit with `docs(redeem): ...` or `docs(announcements): ...` (see `commit-message`).
3. Small PR to `main` with the `documentation` label. **Merging publishes to every user immediately, so confirm the content with the user before opening or merging the PR.**
