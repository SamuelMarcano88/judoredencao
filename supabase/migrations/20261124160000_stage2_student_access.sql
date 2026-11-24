create unique index if not exists student_access_username_lower_uidx
  on public.student_access (lower(username));

drop policy if exists student_access_parent_read on public.student_access;
create policy student_access_parent_read on public.student_access
  for select to authenticated
  using (public.is_parent_of(student_id));

grant select on public.students to authenticated;
grant update on public.students to authenticated;
grant select on public.parent_student to authenticated;
grant select on public.student_access to authenticated;
grant select on public.profiles to authenticated;
