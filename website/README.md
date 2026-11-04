# Live Jury website

Static marketing site for Live Jury: home, privacy policy and account deletion. No build step: upload this folder as-is.

## Publish on GitHub Pages

The site is published from this repo by `.github/workflows/pages.yml`, which uploads **only** the `website/` folder. The Pages folder picker only offers `/ (root)` and `/docs`, and `/docs` holds internal notes that must not be published.

1. On GitHub, open **Settings → Pages → Build and deployment** and set **Source** to **GitHub Actions**.
2. Commit and push to `main`. Any change under `website/` redeploys automatically. You can also run the **Website** workflow by hand from the **Actions** tab.
3. The site goes live at `https://vedikayog15.github.io/livejury/`.

All paths are relative, so the site works at a sub-path or on a custom domain.

## Custom domain

1. Under **Settings → Pages → Custom domain**, enter your domain (for example `livejury.app`) and save. GitHub adds a `CNAME` file to the repo.
2. At your domain registrar:
   - **Apex domain** (`livejury.app`): add four `A` records pointing to `185.199.108.153`, `185.199.109.153`, `185.199.110.153` and `185.199.111.153`.
   - **Subdomain** (`www.livejury.app`): add a `CNAME` record pointing to `<you>.github.io`.
3. Once DNS is verified, tick **Enforce HTTPS**.

## Play Console URLs

- Privacy policy: `https://<your-site>/privacy.html`
- Account deletion: `https://<your-site>/delete-account.html`

## Files

| Path | Purpose |
| --- | --- |
| `index.html` | Who we are and what we do |
| `privacy.html` | Privacy policy |
| `delete-account.html` | Self-service account deletion (calls `jury_delete_my_account` in Supabase) |
| `404.html` | Not-found page that GitHub Pages serves automatically |
| `assets/js/config.js` | Supabase URL and **publishable** key (safe to publish), web-app link, contact email |
| `assets/css/site.css` | All styling. Colours match `lib/design/tokens.dart` in the app |

When the Android app goes live, replace the "Coming soon · Google Play" badge in `index.html` with a link to `https://play.google.com/store/apps/details?id=com.livejury.app`.
