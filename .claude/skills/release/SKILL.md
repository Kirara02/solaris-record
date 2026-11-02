---
name: release
description: Prepare a Solaris Record release (version bump, CHANGELOG, tag). Use when asked to release, cut a version, bump the version or write release notes.
---

# Release

Full details: `docs/RELEASING.md`.

1. Add `## <version>` at the top of `CHANGELOG.md`: a short summary, then `### What's new`, `### Fixes`, `### Notes`. Users read this in the update dialog.
2. Bump `version:` in `pubspec.yaml` (only the part before `+` is used).
3. Run `flutter analyze` (and `flutter test` if asked), then commit `chore(release): <version>` on `dev`. Pushing is outward-facing: confirm with the user first.
4. Push `dev` and open the PR (the `gh` CLI is installed and logged in):

   ```bash
   git push
   gh pr create --base main --head dev --title "chore(release): <version>" --label enhancement --label bug --body "<short English summary of the changes, ending with the Claude Code attribution line>"
   ```

   Keep the body short: a summary, a bullet list of changes, and what was verified. Use the `bug` label only when the release has a fix. CI runs for both the push and the pull request; both must pass (`gh pr checks`; for CI use the PR tools of the app rather than polling).
5. Once the PR is merged and CI on `main` is green, **tagging and pushing to `origin` cannot be undone: ask the user for confirmation first and never do it on your own.** The tag must match `pubspec.yaml` (`v1.6.1`); a suffix (`-beta.1`) makes a pre-release. Tag the merged commit without switching branches:

   ```bash
   git fetch origin && git tag v<version> origin/main && git push origin v<version>
   ```
6. Check the result: `gh run list --workflow Release --limit 1`, then `gh release view v<version> --json assets --jq '.assets[].name'`. The names must keep their `…-android-arm64-v8a.apk` style, and `SHA256SUMS.txt` must be there.
7. After the release: `git switch dev && git merge origin/main && git push`.

Cautions:
- Release file names must keep the `…-android-arm64-v8a.apk`, `…-windows-x64.zip` pattern (`assetSuffixFor` in `lib/src/features/update/domain/update_info.dart`).
- Changes that need no release (redeem codes, announcements) go in a small PR to `main`; see `docs/REDEEM_CODES.md` and `docs/ANNOUNCEMENTS.md`.
