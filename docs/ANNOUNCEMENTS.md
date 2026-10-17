# Announcements

The app reads `announcements.json` from the root of the `main` branch (at most twice a day, switchable in About) and shows the first applicable notice once. Edit the file and push to publish; nothing about the user is sent.

```json
{
  "announcements": [
    {
      "id": "2026-11-api-change",
      "title": { "en": "The game's API changed", "id": "API game berubah" },
      "body": { "en": "Update to 1.2.0 to keep importing.", "id": "Perbarui ke 1.2.0 agar impor tetap jalan." },
      "ctaLabel": { "en": "Open release" },
      "ctaUrl": "https://github.com/Kirara02/solaris-record/releases/latest",
      "minVersion": "1.0.0",
      "maxVersion": "1.1.9",
      "platforms": ["android", "macos", "windows", "linux", "ios"],
      "expires": "2026-12-31T00:00:00Z"
    }
  ]
}
```

- `id`, `title` and `body` are required. Text is a string or a map by language code (`en` is the fallback).
- `ctaUrl` must be `https`, otherwise the button is dropped and the notice stays.
- `minVersion` and `maxVersion` (inclusive), `platforms` and `expires` are optional.
- An `id` that was dismissed is never shown again, so give a changed notice a new id.
