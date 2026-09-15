-- Six pre-confirmed test jurors for The Jury Room.
--
-- TEST AND DEMO PROJECTS ONLY. Every account shares one published password, and
-- the first statement deletes any existing account on these addresses. Never run
-- this against a project with real users.
--
-- Run in the Supabase dashboard SQL editor, which executes as a role with access
-- to the auth schema. Re-running it is safe: it resets the six accounts.
--
-- The public.jury_new_profile trigger on auth.users creates each profile and
-- welcome notification, so no insert into public.profiles is needed here.

begin;

-- 1. Remove earlier versions of these accounts. This cascades through
--    public.profiles into room membership, ballots, history and notifications.
delete from auth.users
where email in (
  'juror1@livejury.test','juror2@livejury.test','juror3@livejury.test',
  'juror4@livejury.test','juror5@livejury.test','juror6@livejury.test'
);

-- 2. Create the accounts with email_confirmed_at already set, which is what
--    lets them sign in without a confirmation email.
with jurors(email, display_name) as (
  values
    ('juror1@livejury.test','Ada Whitlock'),
    ('juror2@livejury.test','Ben Okafor'),
    ('juror3@livejury.test','Cira Delgado'),
    ('juror4@livejury.test','Dmitri Vance'),
    ('juror5@livejury.test','Elena Marsh'),
    ('juror6@livejury.test','Farid Nasser')
),
created as (
  insert into auth.users (
    instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
    confirmation_token, recovery_token, email_change, email_change_token_new
  )
  select
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    j.email,
    extensions.crypt('JuryRoom!2026', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    jsonb_build_object('display_name', j.display_name),
    now(), now(),
    '', '', '', ''
  from jurors j
  returning id, email
)
-- 3. Each user needs a matching email identity row for password sign-in.
insert into auth.identities (
  id, user_id, provider_id, identity_data, provider,
  last_sign_in_at, created_at, updated_at
)
select
  gen_random_uuid(), c.id, c.id::text,
  jsonb_build_object('sub', c.id::text, 'email', c.email),
  'email', now(), now(), now()
from created c;

commit;

-- 4. Verify. Expect six rows, confirmed true, each with a display name.
select
  u.email,
  p.display_name,
  u.email_confirmed_at is not null as confirmed,
  exists(select 1 from auth.identities i where i.user_id = u.id) as has_identity
from auth.users u
left join public.profiles p on p.id = u.id
where u.email like 'juror%@livejury.test'
order by u.email;
