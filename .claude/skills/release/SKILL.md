---
name: release
description: Prepare a Solaris Record release (version bump, CHANGELOG, tag). Use when asked to release, cut a version, bump the version or write release notes.
---

# Release

Full details: `docs/RELEASING.md`.

1. Add `## <version>` at the top of `CHANGELOG.md`: a short summary, then `### What's new`, `### Fixes`, `### Notes`. Users read this in the update dialog.
2. Bump `version:` in `pubspec.yaml` (only the part before `+` is used).
3. Commit `chore(release): <version>` on `dev`, open a PR `dev` -> `main`, wait for green CI.
4. **Tagging and pushing to `origin` cannot be undone: ask the user for confirmation first and never do it on your own.** The tag must match `pubspec.yaml` (`v1.6.1`); a suffix (`-beta.1`) makes a pre-release.
5. After the release: `git switch dev && git merge main && git push`.

Cautions:
- Release file names must keep the `…-android-arm64-v8a.apk`, `…-windows-x64.zip` pattern (`assetSuffixFor` in `lib/src/features/update/domain/update_info.dart`).
- Changes that need no release (redeem codes, announcements) go in a small PR to `main`; see `docs/REDEEM_CODES.md` and `docs/ANNOUNCEMENTS.md`.
