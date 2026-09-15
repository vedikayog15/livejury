# Supabase setup

The Flutter client and SQL contract are implemented. A hosted project is provisioned and
both migrations are applied: all ten tables, the RLS policies, the RPC contract and the
three seeded cases are live. Demo mode remains fully available without any of this.

Sections 1 and 2 describe first-time provisioning and do not need to be repeated for the
current project. See `TEST_ACCOUNTS.md` (local, uncommitted) for the six usable accounts.

## Outstanding configuration

Email confirmation is still enabled (`mailer_autoconfirm: false`) and the project uses the
built-in email sender, which allows roughly two messages per hour. New sign-ups through the
app therefore fail with `over_email_send_rate_limit` once that allowance is spent.

Choose one before real users sign up:

- Turn off **Authentication → Sign In / Providers → Email → Confirm email** for immediate
  sign-in without email delivery. Appropriate for a test or demo deployment.
- Or configure a custom SMTP sender under **Project Settings → Authentication → SMTP** and
  keep confirmation enabled. Appropriate for production.

The existing test accounts are unaffected either way; they were created pre-confirmed
through the Auth admin API.

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

A full six-juror round has been driven against the hosted project through the same RPC
contract the Flutter client uses: six sign-ins, room creation, join-by-code, capacity and
host-only guards, the evidence gate, initial ballots with automatic advance to discussion,
cited messages, final ballots with reason-length enforcement, verdict computation, scoring,
history, notifications and rankings. Ballot privacy was checked directly — a juror selecting
from `ballots` sees only their own row, before and after completion.

Confirmed by that run: the profile/notification trigger on `auth.users`, aggregate counts
staying null until the round completes, and outcome and points matching the specification
(`Not guilty` on a 2–4 split; 60 + 10 per exhibit + 20 for citing).

Still unverified on real devices: hosted email delivery (confirmation and recovery), the
native `app.livejury.room://auth-callback` redirect, and Realtime push over a live socket.
The Realtime publication itself is configured; only end-to-end transport between physical
devices is untested.

Official references: [Flutter initialization](https://supabase.com/docs/reference/dart/initializing), [Flutter quickstart](https://supabase.com/docs/guides/getting-started/quickstarts/flutter), [securing data](https://supabase.com/docs/guides/database/secure-data), [Postgres Changes](https://supabase.com/docs/guides/realtime/postgres-changes).
