create table public.categories (
  id uuid primary key default gen_random_uuid(),
  name_pt text not null,
  name_es text not null,
  sort_order integer not null default 0,
  active boolean not null default true,
  unique (name_pt)
);

create table public.activities (
  id uuid primary key default gen_random_uuid(),
  category_id uuid references public.categories(id) on delete set null,
  name_pt text not null,
  name_es text not null,
  description_pt text,
  description_es text,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.cycle_activities (
  id uuid primary key default gen_random_uuid(),
  cycle_id uuid not null references public.cycles(id) on delete cascade,
  activity_id uuid not null references public.activities(id),
  sort_order integer not null default 0,
  required boolean not null default true,
  unique (cycle_id, activity_id)
);

create table public.student_activity_logs (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.students(id) on delete cascade,
  cycle_activity_id uuid not null references public.cycle_activities(id) on delete cascade,
  completed_by uuid not null references public.profiles(id) default auth.uid(),
  completed_at timestamptz not null default now(),
  unique (student_id, cycle_activity_id)
);

create index activities_category_idx on public.activities(category_id);
create index cycle_activities_cycle_idx
  on public.cycle_activities(cycle_id, sort_order);
create index student_activity_logs_student_idx
  on public.student_activity_logs(student_id);
create index student_activity_logs_cycle_activity_idx
  on public.student_activity_logs(cycle_activity_id);

alter table public.categories enable row level security;
alter table public.activities enable row level security;
alter table public.cycle_activities enable row level security;
alter table public.student_activity_logs enable row level security;

create policy categories_read on public.categories
  for select to authenticated
  using (true);

create policy categories_admin_all on public.categories
  for all to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy activities_read on public.activities
  for select to authenticated
  using (true);

create policy activities_admin_all on public.activities
  for all to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy cycle_activities_read on public.cycle_activities
  for select to authenticated
  using (
    public.is_admin()
    or exists (
      select 1
      from public.student_cycles sc
      where sc.cycle_id = cycle_activities.cycle_id
        and (
          public.is_parent_of(sc.student_id)
          or public.is_student(sc.student_id)
        )
    )
  );

create policy cycle_activities_admin_all on public.cycle_activities
  for all to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy student_activity_logs_read on public.student_activity_logs
  for select to authenticated
  using (
    public.is_admin()
    or public.is_parent_of(student_id)
    or public.is_student(student_id)
  );

create policy student_activity_logs_admin_all on public.student_activity_logs
  for all to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy student_activity_logs_student_insert on public.student_activity_logs
  for insert to authenticated
  with check (
    completed_by = auth.uid()
    and public.is_student(student_id)
    and exists (
      select 1
      from public.student_cycles sc
      join public.cycle_activities ca on ca.cycle_id = sc.cycle_id
      where sc.student_id = student_activity_logs.student_id
        and ca.id = student_activity_logs.cycle_activity_id
    )
  );

create policy student_activity_logs_student_delete on public.student_activity_logs
  for delete to authenticated
  using (
    completed_by = auth.uid()
    and public.is_student(student_id)
  );

grant select, insert, update, delete
  on public.categories, public.activities to authenticated;
grant select, insert, update, delete on public.cycle_activities to authenticated;
grant select, insert, update, delete on public.student_activity_logs to authenticated;
grant select on public.cycles, public.student_cycles, public.belts to authenticated;

create or replace function public.create_training_cycle(
  p_name text,
  p_start_date date,
  p_end_date date,
  p_current_belt_id uuid,
  p_next_belt_id uuid,
  p_student_ids uuid[],
  p_activities jsonb
)
returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_cycle_id uuid;
  v_activity jsonb;
  v_activity_id uuid;
  v_category_id uuid;
  v_student_id uuid;
  v_name_pt text;
  v_name_es text;
  v_category_pt text;
  v_category_es text;
  v_required boolean;
  v_sort_order integer := 0;
begin
  if not public.is_admin() then
    raise exception 'Only administrators can create training cycles.'
      using errcode = '42501';
  end if;

  if length(trim(coalesce(p_name, ''))) < 2
    or length(trim(p_name)) > 100 then
    raise exception 'Cycle name must be 2 to 100 characters.'
      using errcode = '22023';
  end if;
  if p_start_date is null or (p_end_date is not null and p_end_date < p_start_date) then
    raise exception 'The cycle dates are invalid.'
      using errcode = '22023';
  end if;
  if coalesce(cardinality(p_student_ids), 0) = 0 then
    raise exception 'Select at least one student for the cycle.'
      using errcode = '22023';
  end if;
  if p_activities is null or jsonb_typeof(p_activities) <> 'array' then
    raise exception 'Add at least one checklist activity.'
      using errcode = '22023';
  end if;
  if jsonb_array_length(p_activities) = 0 then
    raise exception 'Add at least one checklist activity.'
      using errcode = '22023';
  end if;

  insert into public.cycles (
    name,
    start_date,
    end_date,
    current_belt_id,
    next_belt_id,
    status
  )
  values (
    trim(p_name),
    p_start_date,
    p_end_date,
    p_current_belt_id,
    p_next_belt_id,
    case
      when p_end_date is not null and p_end_date < current_date then 'completed'
      when p_start_date > current_date then 'planned'
      else 'active'
    end
  )
  returning id into v_cycle_id;

  foreach v_student_id in array p_student_ids
  loop
    insert into public.student_cycles (student_id, cycle_id, status)
    values (v_student_id, v_cycle_id, 'active')
    on conflict (student_id, cycle_id) do nothing;
  end loop;

  for v_activity in select value from jsonb_array_elements(p_activities)
  loop
    v_name_pt := trim(coalesce(v_activity->>'namePt', ''));
    v_name_es := trim(coalesce(v_activity->>'nameEs', ''));
    v_category_pt := nullif(trim(coalesce(v_activity->>'categoryPt', '')), '');
    v_category_es := nullif(trim(coalesce(v_activity->>'categoryEs', '')), '');
    v_required := coalesce((v_activity->>'required')::boolean, true);

    if length(v_name_pt) < 2 or length(v_name_pt) > 120
      or length(v_name_es) < 2 or length(v_name_es) > 120 then
      raise exception 'Each activity needs Portuguese and Spanish names of 2 to 120 characters.'
        using errcode = '22023';
    end if;
    if (v_category_pt is null) <> (v_category_es is null) then
      raise exception 'Provide category names in both Portuguese and Spanish.'
        using errcode = '22023';
    end if;
    if length(v_category_pt) > 80 or length(v_category_es) > 80 then
      raise exception 'Category names must not exceed 80 characters.'
        using errcode = '22023';
    end if;

    v_category_id := null;
    if v_category_pt is not null then
      insert into public.categories (name_pt, name_es)
      values (v_category_pt, v_category_es)
      on conflict (name_pt) do nothing;

      select id into v_category_id
      from public.categories
      where name_pt = v_category_pt;
    end if;

    insert into public.activities (category_id, name_pt, name_es)
    values (v_category_id, v_name_pt, v_name_es)
    returning id into v_activity_id;

    insert into public.cycle_activities (
      cycle_id,
      activity_id,
      sort_order,
      required
    )
    values (v_cycle_id, v_activity_id, v_sort_order, v_required);
    v_sort_order := v_sort_order + 1;
  end loop;

  return v_cycle_id;
end;
$$;

revoke all on function public.create_training_cycle(
  text, date, date, uuid, uuid, uuid[], jsonb
) from public;
grant execute on function public.create_training_cycle(
  text, date, date, uuid, uuid, uuid[], jsonb
) to authenticated;
