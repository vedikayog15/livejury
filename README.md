# The Jury Room

**Six perspectives. One room.** An original Flutter social deliberation game with a complete local demo and a Supabase implementation for real shared rooms.

The **After Hours** design combines original Flutter-painted case scenes, an illuminated six-seat chamber, Outfit / Inter typography, soft atmospheric backgrounds, and a floating navigation bar. No stock or AI-generated images. See [DESIGN.md](DESIGN.md) for the design rationale.

## Run the demo

Requires Flutter 3.44 / Dart 3.12 or compatible versions. The project was verified with Flutter 3.44.4 and Dart 3.12.2.

```sh
flutter pub get
flutter run
# Browser:
flutter run -d chrome
```

Choose **Take your seat**. No credentials or network calls are needed for demo gameplay. Public and private demo rooms fill with five visibly labeled simulated jurors. Try **JURY06** in Join with code. Demo room codes are local; Supabase is required to share a room across devices.

The demo includes three original cases, all four evidence formats, a private first vote, chat and evidence references, final reasoning, anonymous aggregate results, participation points, badges, a saved journal, profile preferences, notices, and sample rankings. Transcripts have a playback visualization, not a real audio recording.

## Connect Supabase

No Supabase project or credentials are included. Follow [docs/SUPABASE.md](docs/SUPABASE.md) to create a project, apply the two migrations, configure authentication redirects, and supply the public client configuration.

```sh
cp config/supabase.example.json config/supabase.json
# Fill in the project URL and public publishable key.
flutter run --dart-define-from-file=config/supabase.json
```

Never put a secret or service-role key in the app. Explicit demo entry continues to use local data even when Supabase is configured. Cloud operations report actual errors; they do not silently convert to demo operations.

## Architecture

```text
lib/
  main.dart                    # Three-line entry point
  app/                         # Bootstrap, guarded named routes
  core/
    models/                    # Typed cases, exhibits, rooms, ballots, history
    data/                      # Repository contract, local and Supabase adapters
    state/                     # Controller and inherited dependency scope
  design/
    tokens.dart                # Palette, semantic colors, spacing, typography
    theme/                     # Material 3 theme
    widgets/                   # Surfaces, navigation, controls, original painters
  features/
    onboarding/ auth/ home/ matchmaking/ jury_room/ evidence/
    deliberation/ verdict/ history/ profile/ notifications/ leaderboard/
supabase/
  migrations/                  # Transactional schema, RLS, RPCs, fictional seed
  tests/                       # Real PostgreSQL privacy and game-rule assertions
test/                          # Unit, widget-flow and responsive tests
tool/                          # Case-seed export, icon and preview generation
```

Two functional runtime packages beyond Flutter: `supabase_flutter` and `shared_preferences`. The small official `cupertino_icons` asset package supplies icons for Flutter’s adaptive platform controls. Local demo history, preferences and active rounds persist on the device. Case drafts survive route changes in memory. Supabase sessions use the SDK's session persistence; room updates combine Realtime invalidations and a five-second recovery poll.

## Verify and build

```sh
dart format lib test tool
flutter analyze
flutter test
flutter build web
flutter build apk --debug
```

Additional checks and design review artifacts:

```sh
# Requires local PostgreSQL command-line tools. Creates and removes a test cluster.
bash scripts/test_database.sh
# Render actual Flutter screens with the bundled fonts at phone widths.
flutter test tool/render_previews.dart
# Regenerate the SQL case seed after editing the Dart case library.
dart run tool/export_case_seed.dart
```

Screenshots are written to `artifacts/previews/`. See [docs/VALIDATION.md](docs/VALIDATION.md) for the recorded verification scope.

## Deployment

- **Android demo APK:** `build/app/outputs/flutter-apk/app-debug.apk`. This is installable for testing, not a store-signed release.
- **Web:** publish the contents of `build/web/` to an HTTPS static host. Rebuild with `--dart-define-from-file=config/supabase.json` to enable the connected mode. Hash navigation does not require route rewrites. Configure the deployed URL in Supabase Auth.
- **Android store release:** use an owner-controlled upload key in ignored `android/key.properties`, then `flutter build appbundle --release --dart-define-from-file=config/supabase.json`. The release configuration does not use a debug signing key. See [docs/RELEASE.md](docs/RELEASE.md).
- **iOS:** platform configuration and callback scheme are included. An Apple development team, signing profiles, and device/store verification are needed for distribution; an iOS build is not part of the verified artifacts.

## Deliberation rules

Rooms have six seats. All exhibits must be reviewed before the first ballot. Real discussion opens after all six initial ballots. The host opens final voting, which closes discussion. Every final vote requires 20–2,000 characters of reasoning. Aggregate results are revealed only after six final ballots; a 3–3 result is a hung jury. Leaving an active real round cancels it for everyone without awarding points.

Points reward behavior, not agreement: 60 for completing the case, 10 per reviewed exhibit, and 20 for at least one evidence citation. Reports are stored for an operator to review; no automated moderation service or push notification service is included. All cases are fictional and are not legal advice.

## Credits

Outfit and Inter are bundled under their SIL Open Font Licenses in `assets/fonts/`. Artwork and case narratives were authored specifically for this app. Apple’s public design guidance informed hierarchy and restrained navigation materials; the app uses Flutter Material 3 with an original visual implementation.

The previous unused Firebase scaffolding and unused font assets are preserved in `archives/pre-rebuild-reference.zip`; they are not part of the rebuilt app or deployment bundle.
