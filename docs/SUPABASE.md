# Supabase setup

The Flutter client and SQL contract are implemented. A hosted Supabase project has not been provisioned because the project owner does not yet have one. Demo mode is fully available without this setup.

## 1. Create the project

Create a Supabase project and save its database password privately. Copy the project URL and **publishable key** from its Connect dialog. A legacy public `anon` key also works; `SUPABASE_ANON_KEY` is accepted as a compatibility define. Do not use a service-role or secret key in Flutter.

## 2. Apply the migrations

Use the SQL editor to run these files in order against a **fresh project**:

1. `supabase/migrations/202609060001_jury_schema.sql`
2. `supabase/migrations/202609060002_case_library.sql`

The first file defines tables, permissions, policies, transactional functions and the Auth profile trigger. The second installs the original fictional case library. The schema migration is versioned and intended to be applied once; do not repeatedly paste it into an already-migrated project.

Alternatively, with the Supabase CLI installed and logged in:

```sh
supabase init
supabase link --project-ref YOUR_PROJECT_REF
supabase db push
```

The `supabase/tests/bootstrap_local.sql` file is strictly for isolated plain-PostgreSQL tests. **Do not run it in a hosted Supabase project.** Supabase already provides its Auth schema and roles.

## 3. Configure Auth

Enable email/password authentication. Keep email confirmation enabled for deployed accounts and configure a production email sender through the Supabase dashboard.

Set the Auth **Site URL** to the deployed web app origin. Add the exact deployed web URL with `?recovery=1` to the redirect allowlist. For local browser development, use the actual Flutter dev-server origin/port; a wildcard development redirect can be used in a separate development project.

For native mobile recovery, add:

```text
app.livejury.room://auth-callback?recovery=1
```

Android and iOS are configured to receive this custom callback scheme. The app observes the SDK password-recovery event, presents a new-password form, updates the credential, signs out, and returns to sign-in. Web recovery also recognizes the `recovery=1` callback marker. Test confirmation and recovery emails on your deployed origin and native devices after provisioning.

## 4. Configure Flutter

```sh
cp config/supabase.example.json config/supabase.json
```

Edit the ignored local file:

```json
{
  "SUPABASE_URL": "https://your-project-ref.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "your-public-publishable-key"
}
```

```sh
flutter run --dart-define-from-file=config/supabase.json
flutter build web --dart-define-from-file=config/supabase.json
flutter build apk --debug --dart-define-from-file=config/supabase.json
```

These are compile-time values. Changing the file requires a rebuild/restart. The public key will be included in the compiled client by design; authorization comes from the user's JWT, RLS, limited table grants, and checked database functions.

## 5. Confirm Realtime and shared play

The migration adds `public.rooms` to `supabase_realtime` if that publication exists. Check the dashboard replication/publication configuration and enable `rooms` if needed. Do not publish `ballots`.

Create six confirmed test accounts in separate browsers/devices. One host creates a private room and shares its six-character code. Verify that:

- Six real members appear and a seventh is rejected.
- The host opens the case after all six are seated.
- Each user reviews the exhibits and submits a private first ballot.
- Discussion opens after all six first ballots, with live messages and evidence references.
- The host opens final voting; results stay hidden until all six votes are sealed.
- Each user sees their own reason and history, with only the final aggregate visible to others.
- Closing and reopening a client restores its active room.

Cloud mode deliberately does not simulate missing jurors. Host-disconnect recovery is manual: the host can reconnect, or another juror can leave to cancel an active round. No timeout scheduler or background matchmaker service is included.

## Tables and authority

| Table | Client access |
| --- | --- |
| `profiles` | Read own row; update display name and preferences only |
| `cases` | Authenticated reading of fictional case payloads |
| `rooms`, `room_members` | Read only as a room member |
| `evidence_reviews` | Read own records; writes through checked RPC |
| `ballots` | Owner-only reads, even after completion; immutable client-side |
| `messages` | Room-member reads; writes only during discussion |
| `case_history` | Own records only; server-generated scoring |
| `notifications` | Own records; only `read` is directly mutable |
| `message_reports` | Own reports; operator reviews through trusted backend access |

Room row locks serialize membership and voting mutations. Authenticated clients cannot directly insert room membership or ballots, modify points, or publish a result. Reports are recorded but require a human moderation workflow before community-scale operation.

## What has been verified

The migrations and gameplay/privacy assertions have been executed against a disposable PostgreSQL database with a minimal Auth test harness. This verifies SQL behavior and RLS permissions. Hosted Supabase Auth delivery, Realtime transport, and multi-device callbacks still require the new project and real devices; they are not represented as already live.

Official references: [Flutter initialization](https://supabase.com/docs/reference/dart/initializing), [Flutter quickstart](https://supabase.com/docs/guides/getting-started/quickstarts/flutter), [securing data](https://supabase.com/docs/guides/database/secure-data), [Postgres Changes](https://supabase.com/docs/guides/realtime/postgres-changes).
