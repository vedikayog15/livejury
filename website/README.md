# Live Jury website

Static marketing site for Live Jury: home, privacy policy and account deletion. No build step: upload this folder as-is.

## Publish on GitHub Pages

1. Create a new GitHub repository (for example `livejury-site`).
2. Upload **the contents of this folder** (not the folder itself) to the repository root, including the hidden `.nojekyll` file.
   ```sh
   cd website
   git init && git add . && git commit -m "Live Jury website"
   git branch -M main
   git remote add origin https://github.com/<you>/livejury-site.git
   git push -u origin main
   ```
3. On GitHub, open **Settings → Pages → Build and deployment**, set **Source** to *Deploy from a branch*, and choose `main` and `/ (root)`.
4. After about a minute the site is live at `https://<you>.github.io/livejury-site/`.

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
