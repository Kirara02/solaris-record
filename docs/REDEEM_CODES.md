# Redeem codes

The Explore tab's Redeem Code screen reads `redeem-codes.json` from the root of the `main` branch each time it is opened (or refreshed). The last good copy is kept on the device, so the list still shows offline. Edit the file and merge it into `main` to publish (a push to `dev` changes nothing for users); nothing about the user is sent.

```json
{
  "codes": [
    {
      "code": "WUTHERINGGIFT",
      "rewards": { "en": "Astrite x100, Shell Credit x20000", "id": "Astrite x100, Shell Credit x20000" },
      "source": { "en": "Official" },
      "added": "2026-10-01",
      "expires": "2026-12-31",
      "active": true
    }
  ]
}
```

- `code` is required. Entries without it, and repeated codes (compared ignoring case), are skipped.
- `rewards` and `source` are optional. Text is a string or a map by language code (`en` is the fallback).
- `added` and `expires` are `YYYY-MM-DD` dates. A code works through its whole `expires` day; without `expires` it has no known end date.
- Set `"active": false` when a code stops working before its `expires`, or to retire it. Codes past `expires` or marked inactive move to the Expired list (kept for reference, without a copy button).
- An unreadable file never breaks the screen: the saved copy is shown, or a retry state when there is none.
