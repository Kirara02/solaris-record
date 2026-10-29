---
name: commit-message
description: Write a commit message or pull request for Solaris Record. Use when committing, creating a PR, or choosing a commit type or scope.
---

# Commit and PR conventions

- Format: `type(scope): summary` in English, imperative, lower case, about 72 characters or less. Add a body when the *why* is not obvious.
- Types: `feat`, `fix`, `docs`, `refactor`, `perf`, `test`, `build`, `ci`, `chore` (`chore(deps)` for dependency bumps).
- Scope is optional: `stats`, `import`, `backup`, `accounts`, `info`, `settings`, `i18n`, `theme`, `ci`, `release`, or another feature area.
- Run `flutter analyze` before committing (CI runs the tests).
- Commit on `dev`, not `main`.
- PR labels (they group the release notes): `enhancement`, `bug`, `documentation`, `dependencies`.
- End with the attribution line(s) the session instructions require, if any.

Examples: `feat(stats): add vertical 5★ timeline`, `fix(import): keep the saved link when the network drops`.
