# Release configuration

## Android

The application ID is `com.livejury.app`. Debug APKs use development signing. Production signing is read only from the ignored `android/key.properties` file:

```properties
storeFile=/absolute/path/to/your-upload-key.jks
storePassword=YOUR_PRIVATE_PASSWORD
keyAlias=YOUR_KEY_ALIAS
keyPassword=YOUR_PRIVATE_PASSWORD
```

```sh
flutter build appbundle --release --dart-define-from-file=config/supabase.json
```

Never commit keystores, passwords, or Supabase secret/service keys. Without `key.properties`, the release configuration has no production signing key. Supply your own store listing, privacy policy, content rating, moderation process, and signed release artifact before distribution.

## Web (Firebase Hosting)

The web app is hosted on the Firebase project `live-jury` (see `firebase.json`, `.firebaserc`).

```sh
./scripts/build_web.sh          # flutter build web + generates build/web/site-config.js
firebase deploy --only hosting
```

Static pages ship with the app and are what the Play Console links to:

- `/privacy`: privacy policy (`web/privacy.html`)
- `/delete-account`: self-service account deletion (`web/delete-account.html`), which calls `jury_delete_my_account()` from migration `202611040004_account_deletion.sql`

`site-config.js` is generated from the ignored `config/supabase.json` and is never committed. Add the hosted origin(s) to Supabase Auth → URL Configuration (Site URL and Redirect URLs).

Serve `build/web/` over HTTPS. For subdirectory hosting, pass `--base-href /your-path/`. Keep `index.html` and the bootstrap script short-lived in the host cache so new versions are discovered. Deploy all generated files together. The compiled Flutter renderer may download renderer resources unless built with `--no-web-resources-cdn`; use that option for self-contained static distribution.

Auth callback allowlists must use the real deployed URL. Do not deploy the example placeholder configuration; omit defines for a demo-only build.

## iOS

Open `ios/Runner.xcworkspace`, choose your development team, and set a bundle identifier you control. Update the callback scheme in both platform manifests and the Supabase allowlist if you change it. Use `flutter build ipa` with the configured public client defines after signing is configured.

## Known operational scope

This deliverable is a runnable app with local demo data, build artifacts, a Supabase adapter and tested database rules. No hosted backend has been created. SMTP delivery, platform sign-in callbacks, Realtime across real devices, store signing, push delivery, account deletion, and staffed moderation have not been deployed. In-app reports and notices are implemented; push notifications and an operator dashboard are not.
