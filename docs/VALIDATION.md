# Verification record

Verified on September 7, 2026 with Flutter 3.44.4 / Dart 3.12.2 on macOS. The delivered APK and web bundle run in demo mode; no Supabase credentials are embedded.

## Automated checks

| Check | Result |
| --- | --- |
| `dart format --output=none --set-exit-if-changed lib test tool` | 36 files; no changes required |
| `flutter analyze` | No issues |
| `flutter test` | 19 tests passed |
| `flutter build web --no-web-resources-cdn` | Release web build succeeded; renderer resources included locally |
| `flutter build apk --debug` | Android debug APK built successfully |
| `bash scripts/test_database.sh` | Both migrations applied; 31 PostgreSQL gameplay/privacy assertions passed |
| `flutter test tool/render_previews.dart` | 12 actual Flutter screen captures generated and visually reviewed |

The final complete Flutter command sequence is reproducible with `bash scripts/verify.sh`.

## Covered behavior

- Invitation → demo entry → public room → six seated jurors → briefing → all evidence reviewed → initial ballot → discussion with evidence reference → final reason validation → verdict → saved journal.
- Private case selection, joining with a valid demo code, invalid-code errors, room cancellation, editable profile, read notifications, and a new account's empty journal.
- Repository persistence, retry after failure, duplicate-operation prevention, immutable ballots, tied outcomes, and idempotent participation points.
- Feature layouts at 320, 390 and 560 dp. Additional 320 dp layout checks use 1.6× text scaling, reduced motion, and an open keyboard.
- Database membership capacity, authenticated access, private ballots, hidden partial results, review/phase gates, immutable submissions, final reason validation, scoring, and outsider/anonymous access rejection.

## Visual review

`artifacts/previews/` contains the invitation, lobby, assembly, case file, evidence desk, exhibit, discussion, final ballot, verdict and profile, plus 320/560 dp lobby captures. They render the real Flutter widgets with bundled Fraunces/DM Sans fonts and active shadows. They are review artifacts rather than golden-test baselines.

The design uses original code-painted chamber and case scenes, layered backgrounds and a frosted navigation surface. The official [Cupertino icon asset](https://pub.dev/packages/cupertino_icons) is included for Flutter's adaptive controls, eliminating the web build's missing platform-font warning.

## Verification limits

A hosted Supabase project is not yet available. PostgreSQL rules were exercised with a disposable local Auth harness, not live Supabase Auth or Realtime transport. Email confirmation/recovery delivery, native auth callbacks and six-device shared gameplay require the owner's project and devices. See [SUPABASE.md](SUPABASE.md).

The APK uses debug signing. Store signing, iOS and desktop builds, physical-device accessibility audits, push delivery, and hosted web deployment are not verified. Browser automation was unavailable in this environment; visual review used rendered Flutter widgets. See [RELEASE.md](RELEASE.md) for distribution configuration.
