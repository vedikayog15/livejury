-- The Jury Room. Apply to a fresh Supabase project as the database owner.
-- All content is fictional. Public clients get no table-write authority beyond
-- their profile preferences and notification read state.
begin;
create extension if not exists pgcrypto;

create table public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 display_name text not null check (length(btrim(display_name)) between 2 and 30),
 haptics boolean not null default true,
 notifications boolean not null default true,
 points integer not null default 0 check(points >= 0),
 created_at timestamptz not null default now()
);
create table public.cases (
 id text primary key,
 payload jsonb not null check(jsonb_typeof(payload) = 'object')
);
create table public.rooms (
 id uuid primary key default gen_random_uuid(),
 code text not null unique,
 case_id text not null references public.cases(id),
 host_id uuid not null references public.profiles(id),
 is_private boolean not null default false,
 stage text not null default 'waiting' check(stage in ('waiting','briefing','initialVote','deliberation','finalVote','complete','cancelled')),
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create table public.room_members (
 room_id uuid not null references public.rooms(id) on delete cascade,
 user_id uuid not null references public.profiles(id) on delete cascade,
 display_name text not null,
 joined_at timestamptz not null default now(),
 primary key(room_id,user_id)
);
create index room_members_user_idx on public.room_members(user_id);
create index room_matchmaking_idx on public.rooms(case_id,created_at) where stage='waiting' and not is_private;
create table public.evidence_reviews (
 room_id uuid not null,
 user_id uuid not null,
 exhibit_id text not null,
 created_at timestamptz not null default now(),
 primary key(room_id,user_id,exhibit_id),
 foreign key(room_id,user_id) references public.room_members(room_id,user_id) on delete cascade
);
create table public.ballots (
 room_id uuid not null,
 user_id uuid not null,
 phase text not null check(phase in ('initial','final')),
 choice text not null check(choice in ('responsible','notResponsible')),
 reason text not null default '',
 created_at timestamptz not null default now(),
 primary key(room_id,user_id,phase),
 foreign key(room_id,user_id) references public.room_members(room_id,user_id) on delete cascade,
 check(phase <> 'final' or length(btrim(reason)) between 20 and 2000)
);
create table public.messages (
 id uuid primary key default gen_random_uuid(),
 room_id uuid not null,
 sender_id uuid not null,
 body text not null check(length(btrim(body)) between 1 and 2000),
 exhibit_id text,
 created_at timestamptz not null default now(),
 foreign key(room_id,sender_id) references public.room_members(room_id,user_id) on delete cascade
);
create index messages_room_time_idx on public.messages(room_id,created_at);
create table public.case_history (
 room_id uuid not null references public.rooms(id),
 user_id uuid not null references public.profiles(id) on delete cascade,
 payload jsonb not null,
 created_at timestamptz not null default now(),
 primary key(room_id,user_id)
);
create table public.notifications (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references public.profiles(id) on delete cascade,
 title text not null,
 body text not null,
 read boolean not null default false,
 created_at timestamptz not null default now()
);
create index notifications_user_idx on public.notifications(user_id,created_at desc);
create table public.message_reports (
 message_id uuid not null references public.messages(id) on delete cascade,
 reporter_id uuid not null references public.profiles(id) on delete cascade,
 created_at timestamptz not null default now(),
 primary key(message_id,reporter_id)
);

create function public.jury_new_profile() returns trigger language plpgsql security definer set search_path='' as $$
begin
 insert into public.profiles(id,display_name) values(new.id,left(coalesce(nullif(btrim(new.raw_user_meta_data->>'display_name'),''),'New juror'),30));
 insert into public.notifications(user_id,title,body) values(new.id,'Your seat is waiting','Welcome to the room. Open a case, consider the evidence, and bring your perspective.');
 return new;
end; $$;
create trigger jury_auth_created after insert on auth.users for each row execute function public.jury_new_profile();

create function public.jury_is_member(p_room uuid) returns boolean language sql stable security definer set search_path='' as $$
 select exists(select 1 from public.room_members where room_id=p_room and user_id=auth.uid());
$$;

alter table public.profiles enable row level security;
alter table public.cases enable row level security;
alter table public.rooms enable row level security;
alter table public.room_members enable row level security;
alter table public.evidence_reviews enable row level security;
alter table public.ballots enable row level security;
alter table public.messages enable row level security;
alter table public.case_history enable row level security;
alter table public.notifications enable row level security;
alter table public.message_reports enable row level security;

create policy profile_read on public.profiles for select to authenticated using(id=auth.uid());
create policy profile_preferences on public.profiles for update to authenticated using(id=auth.uid()) with check(id=auth.uid());
create policy case_read on public.cases for select to authenticated using(true);
create policy room_read on public.rooms for select to authenticated using(public.jury_is_member(id));
create policy members_read on public.room_members for select to authenticated using(public.jury_is_member(room_id));
create policy review_read on public.evidence_reviews for select to authenticated using(user_id=auth.uid());
create policy ballot_owner_only on public.ballots for select to authenticated using(user_id=auth.uid());
create policy message_read on public.messages for select to authenticated using(public.jury_is_member(room_id));
create policy history_owner_only on public.case_history for select to authenticated using(user_id=auth.uid());
create policy notice_read on public.notifications for select to authenticated using(user_id=auth.uid());
create policy notice_seen on public.notifications for update to authenticated using(user_id=auth.uid()) with check(user_id=auth.uid());
create policy reports_owner_only on public.message_reports for select to authenticated using(reporter_id=auth.uid());

revoke all on public.profiles,public.cases,public.rooms,public.room_members,public.evidence_reviews,public.ballots,public.messages,public.case_history,public.notifications,public.message_reports from anon,authenticated;
grant select on public.profiles,public.cases,public.rooms,public.room_members,public.evidence_reviews,public.ballots,public.messages,public.case_history,public.notifications,public.message_reports to authenticated;
grant update(display_name,haptics,notifications) on public.profiles to authenticated;
grant update(read) on public.notifications to authenticated;

create function public.jury_open_room(p_case_id text,p_private boolean default false,p_code text default null)
returns uuid language plpgsql security definer set search_path='' as $$
declare v_user uuid:=auth.uid(); v_room public.rooms; v_id uuid; v_name text; v_code text;
begin
 if v_user is null then raise exception 'Sign in to take a seat.'; end if;
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
   -- Locked candidate prevents two clients claiming the final seat together.
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

create function public.jury_leave_room(p_room uuid) returns void language plpgsql security definer set search_path='' as $$
declare r public.rooms; v_next uuid;
begin
 select * into r from public.rooms where id=p_room for update;
 if not public.jury_is_member(p_room) then raise exception 'You are not seated in this room.'; end if;
 if r.stage='waiting' then
  select user_id into v_next from public.room_members where room_id=p_room and user_id<>auth.uid() order by joined_at,user_id limit 1;
  if v_next is null then update public.rooms set stage='cancelled',updated_at=clock_timestamp() where id=p_room;
  elsif r.host_id=auth.uid() then update public.rooms set host_id=v_next,updated_at=clock_timestamp() where id=p_room;
  else update public.rooms set updated_at=clock_timestamp() where id=p_room; end if;
  delete from public.room_members where room_id=p_room and user_id=auth.uid();
 elsif r.stage not in ('complete','cancelled') then
  update public.rooms set stage='cancelled',updated_at=clock_timestamp() where id=p_room;
  insert into public.notifications(user_id,title,body) select user_id,'The room was closed','A juror left before the verdict. This round was cancelled; no points or result were recorded.' from public.room_members where room_id=p_room;
 end if;
end; $$;

create function public.jury_start_room(p_room uuid) returns void language plpgsql security definer set search_path='' as $$
declare r public.rooms;
begin
 select * into r from public.rooms where id=p_room for update;
 if r.host_id is distinct from auth.uid() or not public.jury_is_member(p_room) then raise exception 'Only the host can open the case.'; end if;
 if r.stage<>'waiting' then raise exception 'The case is already open.'; end if;
 if (select count(*) from public.room_members where room_id=p_room)<>6 then raise exception 'All six seats must be filled.'; end if;
 update public.rooms set stage='briefing',updated_at=clock_timestamp() where id=p_room;
end; $$;

create function public.jury_review(p_room uuid,p_exhibit text) returns void language plpgsql security definer set search_path='' as $$
declare r public.rooms;
begin
 select * into r from public.rooms where id=p_room for update;
 if not public.jury_is_member(p_room) then raise exception 'This case is private to its jurors.'; end if;
 if r.stage in ('waiting','cancelled','complete') then raise exception 'Evidence review is not open.'; end if;
 if not exists(select 1 from public.cases c,jsonb_array_elements(c.payload->'evidence') e where c.id=r.case_id and e->>'id'=p_exhibit) then raise exception 'Exhibit not found.'; end if;
 insert into public.evidence_reviews(room_id,user_id,exhibit_id) values(p_room,auth.uid(),p_exhibit) on conflict do nothing;
end; $$;

create function public.jury_send_message(p_room uuid,p_body text,p_exhibit text default null) returns void language plpgsql security definer set search_path='' as $$
declare r public.rooms;
begin
 select * into r from public.rooms where id=p_room for update;
 if not public.jury_is_member(p_room) then raise exception 'You are not seated in this room.'; end if;
 if r.stage<>'deliberation' then raise exception 'Discussion is not open.'; end if;
 if p_body is null or length(btrim(p_body)) not between 1 and 2000 then raise exception 'Write a message of 1–2,000 characters.'; end if;
 if p_exhibit is not null and not exists(select 1 from public.cases c,jsonb_array_elements(c.payload->'evidence') e where c.id=r.case_id and e->>'id'=p_exhibit) then raise exception 'Exhibit not found.'; end if;
 if exists(select 1 from public.messages where sender_id=auth.uid() and room_id=p_room and created_at>now()-interval '1 second') then raise exception 'Give the room a moment before sending again.'; end if;
 insert into public.messages(room_id,sender_id,body,exhibit_id) values(p_room,auth.uid(),btrim(p_body),p_exhibit);
 update public.rooms set updated_at=clock_timestamp() where id=p_room;
end; $$;

create function public.jury_begin_final(p_room uuid) returns void language plpgsql security definer set search_path='' as $$
declare r public.rooms;
begin
 select * into r from public.rooms where id=p_room for update;
 if r.host_id is distinct from auth.uid() or not public.jury_is_member(p_room) then raise exception 'The host opens final voting for the room.'; end if;
 if r.stage<>'deliberation' then raise exception 'All first impressions must be sealed before final voting.'; end if;
 update public.rooms set stage='finalVote',updated_at=clock_timestamp() where id=p_room;
end; $$;

create function public.jury_vote(p_room uuid,p_choice text,p_final boolean default false,p_reason text default '') returns void language plpgsql security definer set search_path='' as $$
declare r public.rooms; c jsonb; v_phase text; v_total integer; v_yes integer; v_outcome text; m record; v_reviewed integer; v_citations integer; v_points integer; v_reason text; v_changed boolean; v_inserted integer;
begin
 select * into r from public.rooms where id=p_room for update;
 if not public.jury_is_member(p_room) then raise exception 'Only this room’s jurors can vote.'; end if;
 if p_choice is null or p_choice not in ('responsible','notResponsible') then raise exception 'Choose one verdict.'; end if;
 select payload into c from public.cases where id=r.case_id;
 if (select count(*) from public.evidence_reviews where room_id=p_room and user_id=auth.uid())<jsonb_array_length(c->'evidence') then raise exception 'Review every exhibit before voting.'; end if;
 v_phase:=case when p_final then 'final' else 'initial' end;
 if exists(select 1 from public.ballots where room_id=p_room and user_id=auth.uid() and phase=v_phase) then raise exception 'Your ballot is already sealed.'; end if;
 if p_final then
  if r.stage<>'finalVote' then raise exception 'Final voting is not open.'; end if;
  if p_reason is null or length(btrim(p_reason)) not between 20 and 2000 then raise exception 'Explain your verdict in 20–2,000 characters.'; end if;
 else
  if r.stage not in ('briefing','initialVote') then raise exception 'Initial voting is not open.'; end if;
 end if;
 insert into public.ballots(room_id,user_id,phase,choice,reason) values(p_room,auth.uid(),v_phase,p_choice,case when p_final then btrim(p_reason) else '' end);
 select count(*) into v_total from public.ballots where room_id=p_room and phase=v_phase;
 if not p_final then
  update public.rooms set stage=case when v_total=6 then 'deliberation' else 'initialVote' end,updated_at=clock_timestamp() where id=p_room;
 elsif v_total<6 then
  update public.rooms set updated_at=clock_timestamp() where id=p_room;
 else
  select count(*) into v_yes from public.ballots where room_id=p_room and phase='final' and choice='responsible';
  v_outcome:=case when v_yes=3 then 'Hung jury' when c->>'category'='Civil' then case when v_yes>3 then 'Liable' else 'Not liable' end else case when v_yes>3 then 'Guilty' else 'Not guilty' end end;
  update public.rooms set stage='complete',updated_at=clock_timestamp() where id=p_room;
  for m in select user_id from public.room_members where room_id=p_room order by user_id loop
   select count(*) into v_reviewed from public.evidence_reviews where room_id=p_room and user_id=m.user_id;
   select count(*) into v_citations from public.messages where room_id=p_room and sender_id=m.user_id and exhibit_id is not null;
   select reason into v_reason from public.ballots where room_id=p_room and user_id=m.user_id and phase='final';
   select a.choice<>b.choice into v_changed from public.ballots a join public.ballots b using(room_id,user_id) where a.room_id=p_room and a.user_id=m.user_id and a.phase='initial' and b.phase='final';
   v_points:=60+v_reviewed*10+case when v_citations>0 then 20 else 0 end;
   insert into public.case_history(room_id,user_id,payload) values(p_room,m.user_id,jsonb_build_object('room_id',p_room,'case_id',r.case_id,'title',c->>'title','outcome',v_outcome,'reason',v_reason,'points',v_points,'reviewed',v_reviewed,'citations',v_citations,'date',now(),'changed_mind',coalesce(v_changed,false))) on conflict do nothing;
   get diagnostics v_inserted=row_count;
   if v_inserted=1 then
    update public.profiles set points=points+v_points where id=m.user_id;
    insert into public.notifications(user_id,title,body) select id,'Case closed · '||(c->>'title'),'Your reasoning has been saved. You earned '||v_points||' participation points.' from public.profiles where id=m.user_id and notifications;
   end if;
  end loop;
 end if;
end; $$;

create function public.jury_room_snapshot(p_room uuid) returns jsonb language plpgsql stable security definer set search_path='' as $$
declare r public.rooms; result jsonb;
begin
 if not public.jury_is_member(p_room) then raise exception 'This room is not available to your account.'; end if;
 select * into r from public.rooms where id=p_room;
 select jsonb_build_object(
  'id',r.id,'code',r.code,'case_id',r.case_id,'host_id',r.host_id,'is_private',r.is_private,'stage',r.stage,
  'jurors',coalesce((select jsonb_agg(jsonb_build_object('id',user_id,'name',display_name,'is_demo',false) order by joined_at,user_id) from public.room_members where room_id=p_room),'[]'::jsonb),
  'reviewed',coalesce((select jsonb_agg(exhibit_id) from public.evidence_reviews where room_id=p_room and user_id=auth.uid()),'[]'::jsonb),
  'initial',(select choice from public.ballots where room_id=p_room and user_id=auth.uid() and phase='initial'),
  'final_decision',(select choice from public.ballots where room_id=p_room and user_id=auth.uid() and phase='final'),
  'reason',coalesce((select reason from public.ballots where room_id=p_room and user_id=auth.uid() and phase='final'),''),
  'final_count',(select count(*) from public.ballots where room_id=p_room and phase='final'),
  'responsible_count',case when r.stage='complete' then (select count(*) from public.ballots where room_id=p_room and phase='final' and choice='responsible') else null end,
  'messages',coalesce((select jsonb_agg(jsonb_build_object('id',m.id,'sender_id',m.sender_id,'name',j.display_name,'body',m.body,'exhibit_id',m.exhibit_id,'system',false) order by m.created_at,m.id) from (select * from public.messages where room_id=p_room order by created_at desc,id desc limit 250) m join public.room_members j on j.room_id=m.room_id and j.user_id=m.sender_id),'[]'::jsonb)
 ) into result;
 return result;
end; $$;

create function public.jury_player_snapshot() returns jsonb language plpgsql stable security definer set search_path='' as $$
declare p public.profiles; v_room uuid;
begin
 if auth.uid() is null then raise exception 'Please sign in again.'; end if;
 select * into strict p from public.profiles where id=auth.uid();
 select r.id into v_room from public.rooms r join public.room_members m on m.room_id=r.id where m.user_id=p.id and r.stage<>'cancelled' order by (r.stage<>'complete') desc,r.created_at desc limit 1;
 return jsonb_build_object('id',p.id,'name',p.display_name,'haptics',p.haptics,'notifications',p.notifications,
 'history',coalesce((select jsonb_agg(payload order by created_at desc) from public.case_history where user_id=p.id),'[]'::jsonb),
 'notices',coalesce((select jsonb_agg(jsonb_build_object('id',id,'title',title,'body',body,'read',read) order by created_at desc) from public.notifications where user_id=p.id),'[]'::jsonb),
 'round',case when v_room is not null then public.jury_room_snapshot(v_room) else null end);
end; $$;

create function public.jury_rankings() returns table(name text,points integer,cases integer) language sql stable security definer set search_path='' as $$
 select p.display_name,p.points,(select count(*)::integer from public.case_history h where h.user_id=p.id) from public.profiles p where auth.uid() is not null order by p.points desc,p.created_at limit 50;
$$;
create function public.jury_report(p_room uuid,p_message uuid) returns void language plpgsql security definer set search_path='' as $$
begin
 if not public.jury_is_member(p_room) or not exists(select 1 from public.messages where id=p_message and room_id=p_room) then raise exception 'Message not available.'; end if;
 insert into public.message_reports(message_id,reporter_id) values(p_message,auth.uid()) on conflict do nothing;
end; $$;

-- Function execution is opt-in. Never let unauthenticated callers use definer RPCs.
revoke all on function public.jury_new_profile() from public,anon,authenticated;
revoke all on function public.jury_is_member(uuid),public.jury_open_room(text,boolean,text),public.jury_leave_room(uuid),public.jury_start_room(uuid),public.jury_review(uuid,text),public.jury_send_message(uuid,text,text),public.jury_begin_final(uuid),public.jury_vote(uuid,text,boolean,text),public.jury_room_snapshot(uuid),public.jury_player_snapshot(),public.jury_rankings(),public.jury_report(uuid,uuid) from public,anon;
grant execute on function public.jury_is_member(uuid),public.jury_open_room(text,boolean,text),public.jury_leave_room(uuid),public.jury_start_room(uuid),public.jury_review(uuid,text),public.jury_send_message(uuid,text,text),public.jury_begin_final(uuid),public.jury_vote(uuid,text,boolean,text),public.jury_room_snapshot(uuid),public.jury_player_snapshot(),public.jury_rankings(),public.jury_report(uuid,uuid) to authenticated;

-- Only a room invalidation row is published. Ballots are never broadcast.
do $$ begin
 if exists(select 1 from pg_publication where pubname='supabase_realtime') and not exists(select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='rooms') then
  alter publication supabase_realtime add table public.rooms;
 end if;
end $$;
commit;
