-- Admin capability for The Jury Room.
--
-- Admin is decided by the database, never by the client. Every admin function
-- re-checks public.jury_is_admin() as its first statement, so a tampered client
-- gains nothing: the worst it can do is call a function that refuses it.
--
-- Apply once to an already-migrated project, then promote yourself with the
-- statement at the bottom of this file.

begin;

alter table public.profiles
  add column if not exists is_admin boolean not null default false,
  add column if not exists suspended boolean not null default false;

-- Neither column is client-writable. The existing grant already lists the only
-- columns a juror may update; this re-states it so a future edit cannot widen
-- it by accident.
revoke update on public.profiles from authenticated;
grant update(display_name, haptics, notifications) on public.profiles to authenticated;

create or replace function public.jury_is_admin() returns boolean
language sql stable security definer set search_path='' as $$
 select coalesce((select is_admin from public.profiles where id = auth.uid()), false);
$$;

-- A suspended juror keeps their account and history but cannot play. Enforced
-- in the transactional functions below, not in the client.
create or replace function public.jury_require_active() returns void
language plpgsql stable security definer set search_path='' as $$
begin
 if coalesce((select suspended from public.profiles where id = auth.uid()), false) then
  raise exception 'This account is suspended. Contact the room administrator.';
 end if;
end; $$;

-- ---------------------------------------------------------------------------
-- Reading

create or replace function public.admin_overview() returns jsonb
language plpgsql stable security definer set search_path='' as $$
begin
 if not public.jury_is_admin() then raise exception 'Administrator access required.'; end if;
 return jsonb_build_object(
  'jurors', (select count(*) from public.profiles),
  'admins', (select count(*) from public.profiles where is_admin),
  'suspended', (select count(*) from public.profiles where suspended),
  'cases', (select count(*) from public.cases),
  'rooms_open', (select count(*) from public.rooms where stage not in ('complete','cancelled')),
  'rooms_complete', (select count(*) from public.rooms where stage='complete'),
  'ballots', (select count(*) from public.ballots),
  'messages', (select count(*) from public.messages),
  'reports', (select count(*) from public.message_reports)
 );
end; $$;

create or replace function public.admin_list_profiles()
returns table(
 id uuid, email text, display_name text, points integer,
 is_admin boolean, suspended boolean, cases integer, created_at timestamptz
)
language plpgsql stable security definer set search_path='' as $$
begin
 if not public.jury_is_admin() then raise exception 'Administrator access required.'; end if;
 return query
  select p.id, u.email::text, p.display_name, p.points, p.is_admin, p.suspended,
   (select count(*)::integer from public.case_history h where h.user_id = p.id),
   p.created_at
  from public.profiles p join auth.users u on u.id = p.id
  order by p.created_at;
end; $$;

create or replace function public.admin_list_cases()
returns table(id text, payload jsonb, rounds integer)
language plpgsql stable security definer set search_path='' as $$
begin
 if not public.jury_is_admin() then raise exception 'Administrator access required.'; end if;
 return query
  select c.id, c.payload,
   (select count(*)::integer from public.rooms r where r.case_id = c.id)
  from public.cases c order by c.id;
end; $$;

-- ---------------------------------------------------------------------------
-- Writing

create or replace function public.admin_update_profile(
 p_user uuid, p_name text default null, p_points integer default null,
 p_suspended boolean default null, p_is_admin boolean default null
) returns void language plpgsql security definer set search_path='' as $$
declare v_admins integer;
begin
 if not public.jury_is_admin() then raise exception 'Administrator access required.'; end if;
 if not exists(select 1 from public.profiles where id = p_user) then
  raise exception 'That juror no longer exists.';
 end if;
 if p_name is not null and length(btrim(p_name)) not between 2 and 30 then
  raise exception 'A display name is 2–30 characters.';
 end if;
 if p_points is not null and p_points < 0 then
  raise exception 'Points cannot be negative.';
 end if;
 -- Never let the room end up with no administrator, including by self-demotion.
 if p_is_admin is false then
  select count(*) into v_admins from public.profiles where is_admin and id <> p_user;
  if v_admins = 0 then raise exception 'This is the only administrator. Promote another account first.'; end if;
 end if;
 if p_suspended is true and p_user = auth.uid() then
  raise exception 'You cannot suspend your own account.';
 end if;
 update public.profiles set
  display_name = coalesce(nullif(btrim(p_name),''), display_name),
  points = coalesce(p_points, points),
  suspended = coalesce(p_suspended, suspended),
  is_admin = coalesce(p_is_admin, is_admin)
 where id = p_user;
end; $$;

create or replace function public.admin_delete_user(p_user uuid)
returns void language plpgsql security definer set search_path='' as $$
declare v_admins integer;
begin
 if not public.jury_is_admin() then raise exception 'Administrator access required.'; end if;
 if p_user = auth.uid() then raise exception 'You cannot delete your own account.'; end if;
 if not exists(select 1 from public.profiles where id = p_user) then
  raise exception 'That juror no longer exists.';
 end if;
 select count(*) into v_admins from public.profiles where is_admin and id <> p_user;
 if v_admins = 0 then raise exception 'This is the only administrator. Promote another account first.'; end if;
 -- Cascades through public.profiles into membership, ballots and history.
 delete from auth.users where id = p_user;
end; $$;

create or replace function public.admin_save_case(p_id text, p_payload jsonb)
returns void language plpgsql security definer set search_path='' as $$
begin
 if not public.jury_is_admin() then raise exception 'Administrator access required.'; end if;
 if p_id is null or p_id !~ '^[a-z0-9-]{3,40}$' then
  raise exception 'A case id is 3–40 characters of lowercase letters, digits and hyphens.';
 end if;
 if jsonb_typeof(p_payload) <> 'object' then raise exception 'The case payload must be an object.'; end if;
 if coalesce(btrim(p_payload->>'title'),'') = '' then raise exception 'The case needs a title.'; end if;
 if coalesce(btrim(p_payload->>'question'),'') = '' then raise exception 'The case needs a question to resolve.'; end if;
 if (p_payload->>'category') not in ('Criminal','Civil') then raise exception 'Category must be Criminal or Civil.'; end if;
 if jsonb_typeof(p_payload->'evidence') <> 'array' or jsonb_array_length(p_payload->'evidence') < 1 then
  raise exception 'The case needs at least one exhibit.';
 end if;
 insert into public.cases(id, payload) values (p_id, p_payload || jsonb_build_object('id', p_id))
 on conflict(id) do update set payload = excluded.payload;
end; $$;

create or replace function public.admin_delete_case(p_id text)
returns void language plpgsql security definer set search_path='' as $$
begin
 if not public.jury_is_admin() then raise exception 'Administrator access required.'; end if;
 if exists(select 1 from public.rooms where case_id = p_id) then
  raise exception 'This case has been played and is kept for those records. Retire it instead of deleting it.';
 end if;
 delete from public.cases where id = p_id;
end; $$;

-- ---------------------------------------------------------------------------
-- Suspension is enforced where play happens.

create or replace function public.jury_open_room(p_case_id text, p_private boolean default false, p_code text default null)
returns uuid language plpgsql security definer set search_path='' as $$
declare v_user uuid:=auth.uid(); v_room public.rooms; v_id uuid; v_name text; v_code text;
begin
 if v_user is null then raise exception 'Sign in to take a seat.'; end if;
 perform public.jury_require_active();
 perform pg_advisory_xact_lock(hashtextextended(v_user::text,0));
 if exists(select 1 from public.room_members m join public.rooms r on r.id=m.room_id where m.user_id=v_user and r.stage not in ('complete','cancelled')) then raise exception 'You already have a seat. Resume or leave your current room.'; end if;
 select display_name into strict v_name from public.profiles where id=v_user;
 if p_code is not null then
  if p_code !~ '^[A-Z0-9]{6}$' then raise exception 'Enter a six-character room code.'; end if;
  select * into v_room from public.rooms where code=p_code for update;
  if v_room.id is null then raise exception 'Room not found. Check the code and try again.'; end if;
  if v_room.stage<>'waiting' then raise exception 'This room has already started or ended.'; end if;
  if (select count(*) from public.room_members where room_id=v_room.id)>=6 then raise exception 'This room is full. Ask the host for a new room.'; end if;
  v_id:=v_room.id;
 else
  if not exists(select 1 from public.cases where id=p_case_id) then raise exception 'Case not found.'; end if;
  if not p_private then
   select r.* into v_room from public.rooms r where r.case_id=p_case_id and not r.is_private and r.stage='waiting'
    and (select count(*) from public.room_members m where m.room_id=r.id)<6 order by r.created_at limit 1 for update skip locked;
   v_id:=v_room.id;
  end if;
  if v_id is null then
   loop
    v_code:=upper(substr(replace(gen_random_uuid()::text,'-',''),1,6));
    begin
     insert into public.rooms(code,case_id,host_id,is_private) values(v_code,p_case_id,v_user,p_private) returning id into v_id;
     exit;
    exception when unique_violation then null;
    end;
   end loop;
  end if;
 end if;
 insert into public.room_members(room_id,user_id,display_name) values(v_id,v_user,v_name);
 update public.rooms set updated_at=clock_timestamp() where id=v_id;
 return v_id;
end; $$;

create or replace function public.jury_send_message(p_room uuid, p_body text, p_exhibit text default null)
returns void language plpgsql security definer set search_path='' as $$
declare r public.rooms;
begin
 perform public.jury_require_active();
 select * into r from public.rooms where id=p_room for update;
 if not public.jury_is_member(p_room) then raise exception 'You are not seated in this room.'; end if;
 if r.stage<>'deliberation' then raise exception 'Discussion is not open.'; end if;
 if p_body is null or length(btrim(p_body)) not between 1 and 2000 then raise exception 'Write a message of 1–2,000 characters.'; end if;
 if p_exhibit is not null and not exists(select 1 from public.cases c,jsonb_array_elements(c.payload->'evidence') e where c.id=r.case_id and e->>'id'=p_exhibit) then raise exception 'Exhibit not found.'; end if;
 if exists(select 1 from public.messages where sender_id=auth.uid() and room_id=p_room and created_at>now()-interval '1 second') then raise exception 'Give the room a moment before sending again.'; end if;
 insert into public.messages(room_id,sender_id,body,exhibit_id) values(p_room,auth.uid(),btrim(p_body),p_exhibit);
 update public.rooms set updated_at=clock_timestamp() where id=p_room;
end; $$;

-- The player snapshot carries both flags so the client can show the admin area
-- and a suspended notice. They remain advisory: the server decides.
create or replace function public.jury_player_snapshot() returns jsonb
language plpgsql stable security definer set search_path='' as $$
declare p public.profiles; v_room uuid;
begin
 if auth.uid() is null then raise exception 'Please sign in again.'; end if;
 select * into strict p from public.profiles where id=auth.uid();
 select r.id into v_room from public.rooms r join public.room_members m on m.room_id=r.id where m.user_id=p.id and r.stage<>'cancelled' order by (r.stage<>'complete') desc,r.created_at desc limit 1;
 return jsonb_build_object('id',p.id,'name',p.display_name,'haptics',p.haptics,'notifications',p.notifications,
 'is_admin',p.is_admin,'suspended',p.suspended,
 'history',coalesce((select jsonb_agg(payload order by created_at desc) from public.case_history where user_id=p.id),'[]'::jsonb),
 'notices',coalesce((select jsonb_agg(jsonb_build_object('id',id,'title',title,'body',body,'read',read) order by created_at desc) from public.notifications where user_id=p.id),'[]'::jsonb),
 'round',case when v_room is not null then public.jury_room_snapshot(v_room) else null end);
end; $$;

-- ---------------------------------------------------------------------------
-- Execution is opt-in, exactly as for the gameplay functions.

revoke all on function
 public.jury_is_admin(), public.jury_require_active(),
 public.admin_overview(), public.admin_list_profiles(), public.admin_list_cases(),
 public.admin_update_profile(uuid,text,integer,boolean,boolean),
 public.admin_delete_user(uuid), public.admin_save_case(text,jsonb), public.admin_delete_case(text)
 from public, anon;

grant execute on function
 public.jury_is_admin(), public.jury_require_active(),
 public.admin_overview(), public.admin_list_profiles(), public.admin_list_cases(),
 public.admin_update_profile(uuid,text,integer,boolean,boolean),
 public.admin_delete_user(uuid), public.admin_save_case(text,jsonb), public.admin_delete_case(text)
 to authenticated;

commit;

-- ---------------------------------------------------------------------------
-- Promote the first administrator. Change the address, then run this once.
--
--   update public.profiles set is_admin = true
--   where id = (select id from auth.users where email = 'you@example.com');
--
-- Verify:
--   select u.email, p.is_admin, p.suspended
--   from public.profiles p join auth.users u on u.id = p.id
--   where p.is_admin;
