create table public.attendance (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.students(id) on delete cascade,
  cycle_id uuid not null references public.cycles(id) on delete cascade,
  class_date date not null,
  status text not null check (status in ('present', 'absent', 'excused')),
  observation text check (observation is null or length(observation) <= 500),
  marked_by uuid not null references public.profiles(id) default auth.uid(),
  marked_at timestamptz not null default now(),
  unique (student_id, cycle_id, class_date)
);

create table public.technical_requirements (
  id uuid primary key default gen_random_uuid(),
  belt_id uuid not null references public.belts(id) on delete cascade,
  name_pt text not null check (length(trim(name_pt)) between 2 and 120),
  name_es text not null check (length(trim(name_es)) between 2 and 120),
  description_pt text check (
    description_pt is null or length(description_pt) <= 500
  ),
  description_es text check (
    description_es is null or length(description_es) <= 500
  ),
  sort_order integer not null default 0 check (sort_order >= 0),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (belt_id, name_pt)
);

create table public.student_technical_evaluations (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.students(id) on delete cascade,
  cycle_id uuid not null references public.cycles(id) on delete cascade,
  requirement_id uuid not null references public.technical_requirements(id) on delete cascade,
  status text not null check (status in ('developing', 'needs_work', 'achieved')),
  observation text check (observation is null or length(observation) <= 1000),
  evaluated_by uuid not null references public.profiles(id) default auth.uid(),
  evaluated_at timestamptz not null default now(),
  unique (student_id, cycle_id, requirement_id)
);

create index attendance_student_date_idx
  on public.attendance(student_id, class_date desc);
create index attendance_cycle_date_idx
  on public.attendance(cycle_id, class_date);
create index technical_requirements_belt_idx
  on public.technical_requirements(belt_id, sort_order);
create index student_technical_evaluations_student_cycle_idx
  on public.student_technical_evaluations(student_id, cycle_id);
create index student_technical_evaluations_requirement_idx
  on public.student_technical_evaluations(requirement_id);

alter table public.attendance enable row level security;
alter table public.technical_requirements enable row level security;
alter table public.student_technical_evaluations enable row level security;

create policy attendance_read on public.attendance
  for select to authenticated
  using (
    public.is_admin()
    or public.is_parent_of(student_id)
    or public.is_student(student_id)
  );

create policy attendance_admin_all on public.attendance
  for all to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy technical_requirements_read on public.technical_requirements
  for select to authenticated
  using (true);

create policy technical_requirements_admin_all on public.technical_requirements
  for all to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy student_technical_evaluations_read
  on public.student_technical_evaluations
  for select to authenticated
  using (
    public.is_admin()
    or public.is_parent_of(student_id)
    or public.is_student(student_id)
  );

create policy student_technical_evaluations_admin_all
  on public.student_technical_evaluations
  for all to authenticated
  using (public.is_admin())
  with check (public.is_admin());

grant select, insert, update, delete on public.attendance to authenticated;
grant select, insert, update, delete
  on public.technical_requirements to authenticated;
grant select, insert, update, delete
  on public.student_technical_evaluations to authenticated;

create or replace function public.record_cycle_attendance(
  p_cycle_id uuid,
  p_class_date date,
  p_records jsonb
)
returns integer
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_record jsonb;
  v_student_id uuid;
  v_status text;
  v_observation text;
  v_saved_count integer := 0;
begin
  if not public.is_admin() then
    raise exception 'Only administrators can record attendance.'
      using errcode = '42501';
  end if;
  if p_cycle_id is null or p_class_date is null then
    raise exception 'Select a cycle and class date.'
      using errcode = '22023';
  end if;
  if p_records is null or jsonb_typeof(p_records) <> 'array' then
    raise exception 'Attendance records must be an array.'
      using errcode = '22023';
  end if;
  if jsonb_array_length(p_records) = 0 then
    raise exception 'Attendance records cannot be empty.'
      using errcode = '22023';
  end if;

  for v_record in select value from jsonb_array_elements(p_records)
  loop
    v_student_id := (v_record->>'studentId')::uuid;
    v_status := v_record->>'status';
    v_observation := nullif(trim(coalesce(v_record->>'observation', '')), '');

    if v_status is null or v_status not in ('present', 'absent', 'excused') then
      raise exception 'Attendance status is invalid.'
        using errcode = '22023';
    end if;
    if length(v_observation) > 500 then
      raise exception 'Attendance observations must not exceed 500 characters.'
        using errcode = '22023';
    end if;
    if not exists (
      select 1
      from public.student_cycles sc
      where sc.student_id = v_student_id
        and sc.cycle_id = p_cycle_id
    ) then
      raise exception 'Student is not enrolled in the selected cycle.'
        using errcode = '22023';
    end if;

    insert into public.attendance (
      student_id,
      cycle_id,
      class_date,
      status,
      observation,
      marked_by,
      marked_at
    )
    values (
      v_student_id,
      p_cycle_id,
      p_class_date,
      v_status,
      v_observation,
      auth.uid(),
      now()
    )
    on conflict (student_id, cycle_id, class_date) do update
    set
      status = excluded.status,
      observation = excluded.observation,
      marked_by = excluded.marked_by,
      marked_at = excluded.marked_at;
    v_saved_count := v_saved_count + 1;
  end loop;

  return v_saved_count;
end;
$$;

revoke all on function public.record_cycle_attendance(uuid, date, jsonb)
  from public;
grant execute on function public.record_cycle_attendance(uuid, date, jsonb)
  to authenticated;

create or replace function public.save_student_technical_evaluation(
  p_student_id uuid,
  p_cycle_id uuid,
  p_requirement_id uuid,
  p_status text,
  p_observation text
)
returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_evaluation_id uuid;
begin
  if not public.is_admin() then
    raise exception 'Only administrators can evaluate technical requirements.'
      using errcode = '42501';
  end if;
  if p_status is null
    or p_status not in ('developing', 'needs_work', 'achieved') then
    raise exception 'Technical evaluation status is invalid.'
      using errcode = '22023';
  end if;
  if length(nullif(trim(coalesce(p_observation, '')), '')) > 1000 then
    raise exception 'Technical observations must not exceed 1000 characters.'
      using errcode = '22023';
  end if;
  if not exists (
    select 1
    from public.student_cycles sc
    join public.cycles c on c.id = sc.cycle_id
    join public.technical_requirements tr on tr.id = p_requirement_id
    where sc.student_id = p_student_id
      and sc.cycle_id = p_cycle_id
      and tr.belt_id = c.next_belt_id
      and tr.active
  ) then
    raise exception 'Requirement does not belong to this student cycle.'
      using errcode = '22023';
  end if;

  insert into public.student_technical_evaluations (
    student_id,
    cycle_id,
    requirement_id,
    status,
    observation,
    evaluated_by,
    evaluated_at
  )
  values (
    p_student_id,
    p_cycle_id,
    p_requirement_id,
    p_status,
    nullif(trim(coalesce(p_observation, '')), ''),
    auth.uid(),
    now()
  )
  on conflict (student_id, cycle_id, requirement_id) do update
  set
    status = excluded.status,
    observation = excluded.observation,
    evaluated_by = excluded.evaluated_by,
    evaluated_at = excluded.evaluated_at
  returning id into v_evaluation_id;

  return v_evaluation_id;
end;
$$;

revoke all on function public.save_student_technical_evaluation(
  uuid, uuid, uuid, text, text
) from public;
grant execute on function public.save_student_technical_evaluation(
  uuid, uuid, uuid, text, text
) to authenticated;
