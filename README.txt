# Studio Redshine Wedding Package Builder

Files:
- `index.html` — customer-facing wedding package builder. This is the file to send to customers / use as the GitHub Pages home page.
- `admin-pricing.html` — owner-only pricing editor (PIN/owner-code protected).
- `pricing.json` — committed fallback pricing configuration used on first load.

Important:
1. The customer builder keeps the detailed English + Sinhala descriptions on every service card.
2. Photographer count + coverage duration are a single mutually-exclusive option, so there is no double charge.
3. Admin pricing is shared through same-origin localStorage when both pages are used on the same browser/origin.
4. For public GitHub customers on other devices, the static site uses `pricing.json` as the shared source. After changing prices in the admin page, use its Export Pricing function (it downloads a file named `pricing.json`) and replace the repository's `pricing.json` with that file, then refresh the public customer page.
