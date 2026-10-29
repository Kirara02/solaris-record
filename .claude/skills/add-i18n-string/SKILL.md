---
name: add-i18n-string
description: Add or change a UI string in Solaris Record. Use when adding, renaming or editing any user-visible text, translation, i18n key or slang string.
---

# Add an i18n string

1. Add the key to **all five** files in `lib/src/shared/i18n/`: `en`, `id`, `ja`, `zh-Hans`, `zh-Hant` (`<locale>.i18n.json`). Use the same group in each; `en` is the base, so follow its key order.
2. Parameters use `{name}` and must be identical in every language.
3. Run `dart run slang`. It is configured by `slang.yaml` (not `slang_build_runner`). The output in `i18n/gen/` is git-ignored; never commit it.
4. Use the string as `context.t.<group>.<key>`, then check with `flutter analyze`.

Cautions:
- Locales are loaded eagerly (`lazy: false`); do not change that (deferred loading crashed release builds).
- Log messages stay in English via `Logger('area')`, and never contain a raw UID, convene URL or token (use `sanitizeUid` / `sanitizeUrl`).

Background: `CLAUDE.md` (the i18n entry).
