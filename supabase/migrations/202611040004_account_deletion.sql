-- Self-service account deletion, required for store listing.
--
-- A juror may delete their own account from the app or from the public
-- /delete-account web page. Everything account-linked cascades from
-- auth.users through public.profiles. Rooms are shared with other jurors, so a
-- deleted host leaves the room in place with no host instead of removing it.

begin;

alter table public.rooms alter column host_id drop not null;
alter table public.rooms drop constraint if exists rooms_host_id_fkey;
alter table public.rooms
  add constraint rooms_host_id_fkey
  foreign key (host_id) references public.profiles(id) on delete set null;

create or replace function public.jury_delete_my_account()
returns void language plpgsql security definer set search_path='' as $$
declare v_user uuid := auth.uid(); v_room uuid;
begin
 if v_user is null then raise exception 'Sign in to delete your account.'; end if;
 if exists(select 1 from public.profiles where id = v_user and is_admin)
    and not exists(select 1 from public.profiles where is_admin and id <> v_user) then
  raise exception 'This is the only administrator. Promote another account first.';
 end if;
 -- Leave open rooms the normal way so hosting passes on and other jurors are
 -- notified, exactly as if this juror had walked out.
 for v_room in
  select m.room_id from public.room_members m join public.rooms r on r.id = m.room_id
  where m.user_id = v_user and r.stage not in ('complete','cancelled')
 loop
  perform public.jury_leave_room(v_room);
 end loop;
 delete from auth.users where id = v_user;
end; $$;

revoke all on function public.jury_delete_my_account() from public, anon;
grant execute on function public.jury_delete_my_account() to authenticated;

commit;
