create type public.user_role as enum ('admin', 'parent', 'student');
create type public.profile_language as enum ('pt', 'es');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  email text,
  role public.user_role not null,
  preferred_language public.profile_language not null default 'pt',
  created_at timestamptz not null default now()
);

create table public.students (
  id uuid primary key default gen_random_uuid(),
  full_name text not null,
  birth_date date,
  current_belt_id uuid,
  photo_url text,
  created_at timestamptz not null default now()
);

create table public.parent_student (
  id uuid primary key default gen_random_uuid(),
  parent_user_id uuid not null references public.profiles(id) on delete cascade,
  student_id uuid not null references public.students(id) on delete cascade,
  relationship text,
  created_at timestamptz not null default now(),
  unique (parent_user_id, student_id)
);

create table public.student_access (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.students(id) on delete cascade,
  auth_user_id uuid not null unique references auth.users(id) on delete cascade,
  username text not null unique,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.belts (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  name_pt text,
  name_es text,
  color text not null,
  sequence integer not null unique,
  active boolean not null default true
);

alter table public.students
  add constraint students_belt_fk
  foreign key (current_belt_id) references public.belts(id);

create table public.cycles (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  start_date date not null,
  end_date date,
  current_belt_id uuid references public.belts(id),
  next_belt_id uuid references public.belts(id),
  status text not null default 'planned'
);

create table public.student_cycles (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.students(id) on delete cascade,
  cycle_id uuid not null references public.cycles(id) on delete cascade,
  status text not null default 'active',
  final_decision text,
  final_observation text,
  unique (student_id, cycle_id)
);

create index parent_student_parent_idx on public.parent_student(parent_user_id);
create index parent_student_student_idx on public.parent_student(student_id);
create index student_access_student_idx on public.student_access(student_id);
create index student_access_username_idx on public.student_access(username);
create index student_cycles_student_idx on public.student_cycles(student_id);
create index student_cycles_cycle_idx on public.student_cycles(cycle_id);

create or replace function public.current_user_role()
returns public.user_role
language sql
stable
security definer
set search_path = public
as $$
  select role from public.profiles where id = auth.uid();
$$;

grant execute on function public.current_user_role() to authenticated;

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.current_user_role() = 'admin';
$$;

create or replace function public.is_parent_of(p_student_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.parent_student ps
    where ps.student_id = p_student_id
      and ps.parent_user_id = auth.uid()
  );
$$;

create or replace function public.is_student(p_student_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.student_access sa
    where sa.student_id = p_student_id
      and sa.auth_user_id = auth.uid()
      and sa.active
  );
$$;

grant execute on function public.is_admin() to authenticated;
grant execute on function public.is_parent_of(uuid) to authenticated;
grant execute on function public.is_student(uuid) to authenticated;

create or replace function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (
    id,
    full_name,
    email,
    role,
    preferred_language
  )
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', new.email, 'Usuário'),
    new.email,
    'parent',
    coalesce(
      (new.raw_user_meta_data->>'preferred_language')::public.profile_language,
      'pt'
    )
  )
  on conflict (id) do update
  set
    full_name = excluded.full_name,
    email = excluded.email;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_auth_user();

alter table public.profiles enable row level security;
alter table public.students enable row level security;
alter table public.parent_student enable row level security;
alter table public.student_access enable row level security;
alter table public.belts enable row level security;
alter table public.cycles enable row level security;
alter table public.student_cycles enable row level security;

create policy profiles_select on public.profiles
  for select to authenticated
  using (
    id = auth.uid()
    or public.is_admin()
  );

create policy profiles_update_self on public.profiles
  for update to authenticated
  using (id = auth.uid())
  with check (
    id = auth.uid()
    and role = public.current_user_role()
  );

create policy students_select on public.students
  for select to authenticated
  using (
    public.is_admin()
    or public.is_parent_of(id)
    or public.is_student(id)
  );

create policy students_admin_all on public.students
  for all to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy parent_student_admin on public.parent_student
  for all to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy parent_student_parent on public.parent_student
  for select to authenticated
  using (parent_user_id = auth.uid());

create policy student_access_admin on public.student_access
  for all to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy student_access_self on public.student_access
  for select to authenticated
  using (auth_user_id = auth.uid());

create policy belts_read on public.belts
  for select to authenticated
  using (true);

create policy belts_admin on public.belts
  for all to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy cycles_read on public.cycles
  for select to authenticated
  using (
    public.is_admin()
    or exists (
      select 1
      from public.student_cycles sc
      where sc.cycle_id = cycles.id
        and (
          public.is_parent_of(sc.student_id)
          or public.is_student(sc.student_id)
        )
    )
  );

create policy cycles_admin on public.cycles
  for all to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy student_cycles_read on public.student_cycles
  for select to authenticated
  using (
    public.is_admin()
    or public.is_parent_of(student_id)
    or public.is_student(student_id)
  );

create policy student_cycles_admin on public.student_cycles
  for all to authenticated
  using (public.is_admin())
  with check (public.is_admin());
