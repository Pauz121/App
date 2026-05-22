-- Gestione Database Personal Trainer - Supabase SaaS schema
-- Passwords are handled only by Supabase Auth. No public table stores passwords.

create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('trainer', 'client', 'super_admin')),
  email text not null,
  first_name text not null,
  last_name text not null,
  avatar_url text,
  phone text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.subscription_plans (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  description text not null,
  monthly_price numeric(10,2) not null default 0,
  yearly_price numeric(10,2),
  max_clients integer,
  trial_days integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  check (max_clients is null or max_clients > 0)
);

create table if not exists public.trainers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.profiles(id) on delete cascade,
  business_name text not null,
  vat_number text,
  phone text,
  bio text,
  max_clients integer,
  status text not null default 'trialing' check (status in ('active', 'trialing', 'suspended', 'cancelled')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.trainer_subscriptions (
  id uuid primary key default gen_random_uuid(),
  trainer_id uuid not null references public.trainers(id) on delete cascade,
  plan_id uuid not null references public.subscription_plans(id),
  status text not null check (status in ('trialing', 'active', 'past_due', 'cancelled', 'expired')),
  starts_at timestamptz not null default now(),
  trial_ends_at timestamptz,
  current_period_start timestamptz,
  current_period_end timestamptz,
  cancelled_at timestamptz,
  provider text,
  provider_subscription_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.clients (
  id uuid primary key default gen_random_uuid(),
  trainer_id uuid not null references public.trainers(id) on delete cascade,
  user_id uuid unique references public.profiles(id) on delete set null,
  status text not null default 'pending_registration' check (status in ('pending_registration', 'active', 'archived')),
  first_name text not null,
  last_name text not null,
  email text,
  phone text,
  birth_date date,
  height_cm numeric(6,2),
  initial_weight_kg numeric(6,2),
  current_weight_kg numeric(6,2),
  goal text,
  notes text,
  joined_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.client_invite_codes (
  id uuid primary key default gen_random_uuid(),
  trainer_id uuid not null references public.trainers(id) on delete cascade,
  client_id uuid not null references public.clients(id) on delete cascade,
  code text not null unique,
  status text not null default 'active' check (status in ('active', 'used', 'expired', 'revoked')),
  expires_at timestamptz not null,
  used_at timestamptz,
  used_by_user_id uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.appointments (
  id uuid primary key default gen_random_uuid(),
  trainer_id uuid not null references public.trainers(id) on delete cascade,
  client_id uuid not null references public.clients(id) on delete cascade,
  title text not null,
  session_type text not null,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  status text not null default 'scheduled' check (status in ('scheduled', 'completed', 'cancelled')),
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (ends_at > starts_at)
);

create table if not exists public.machines (
  id uuid primary key default gen_random_uuid(),
  trainer_id uuid not null references public.trainers(id) on delete cascade,
  name text not null,
  muscle_group text not null,
  description text,
  usage_notes text,
  image_url text,
  is_available boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.workout_plans (
  id uuid primary key default gen_random_uuid(),
  trainer_id uuid not null references public.trainers(id) on delete cascade,
  client_id uuid not null references public.clients(id) on delete cascade,
  name text not null,
  goal text,
  starts_at date,
  ends_at date,
  status text not null default 'draft' check (status in ('active', 'archived', 'draft')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.workout_days (
  id uuid primary key default gen_random_uuid(),
  workout_plan_id uuid not null references public.workout_plans(id) on delete cascade,
  name text not null,
  day_order integer not null,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.exercises (
  id uuid primary key default gen_random_uuid(),
  workout_day_id uuid not null references public.workout_days(id) on delete cascade,
  machine_id uuid references public.machines(id) on delete set null,
  name text not null,
  muscle_group text not null,
  sets integer not null,
  reps text not null,
  rest_seconds integer,
  suggested_load text,
  technical_notes text,
  exercise_order integer not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (sets > 0)
);

create table if not exists public.nutrition_plans (
  id uuid primary key default gen_random_uuid(),
  trainer_id uuid not null references public.trainers(id) on delete cascade,
  client_id uuid not null references public.clients(id) on delete cascade,
  name text not null,
  daily_calories integer not null,
  proteins_g integer,
  carbs_g integer,
  fats_g integer,
  target_weight_kg numeric(6,2),
  notes text,
  starts_at date,
  ends_at date,
  status text not null default 'draft' check (status in ('active', 'archived', 'draft')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (daily_calories > 0)
);

create table if not exists public.meals (
  id uuid primary key default gen_random_uuid(),
  nutrition_plan_id uuid not null references public.nutrition_plans(id) on delete cascade,
  name text not null,
  meal_time time,
  meal_order integer not null,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.meal_foods (
  id uuid primary key default gen_random_uuid(),
  meal_id uuid not null references public.meals(id) on delete cascade,
  food_name text not null,
  quantity text not null,
  calories integer,
  proteins_g numeric(7,2),
  carbs_g numeric(7,2),
  fats_g numeric(7,2),
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.progress_entries (
  id uuid primary key default gen_random_uuid(),
  trainer_id uuid not null references public.trainers(id) on delete cascade,
  client_id uuid not null references public.clients(id) on delete cascade,
  entry_date date not null default current_date,
  weight_kg numeric(6,2),
  waist_cm numeric(6,2),
  chest_cm numeric(6,2),
  arm_cm numeric(6,2),
  leg_cm numeric(6,2),
  notes text,
  created_by_user_id uuid not null references public.profiles(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.progress_photos (
  id uuid primary key default gen_random_uuid(),
  progress_entry_id uuid not null references public.progress_entries(id) on delete cascade,
  trainer_id uuid not null references public.trainers(id) on delete cascade,
  client_id uuid not null references public.clients(id) on delete cascade,
  photo_type text not null check (photo_type in ('front', 'side', 'back', 'other')),
  storage_path text not null unique,
  public_url text,
  created_at timestamptz not null default now()
);

create table if not exists public.app_audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_user_id uuid references public.profiles(id) on delete set null,
  trainer_id uuid references public.trainers(id) on delete set null,
  client_id uuid references public.clients(id) on delete set null,
  action text not null,
  entity_type text not null,
  entity_id uuid,
  metadata jsonb,
  created_at timestamptz not null default now()
);

insert into public.subscription_plans (name, slug, description, monthly_price, yearly_price, max_clients, trial_days, is_active)
values
  ('Free Trial 15 giorni', 'trial_15', 'Prova gratuita con massimo 5 clienti.', 0, null, 5, 15, true),
  ('Basic', 'basic', 'Per trainer indipendenti con fino a 20 clienti.', 19.90, 199.00, 20, 0, true),
  ('Pro', 'pro', 'Per trainer in crescita con fino a 60 clienti.', 49.90, 499.00, 60, 0, true),
  ('Studio', 'studio', 'Per studi e palestre con alto volume clienti.', 99.90, 999.00, 500, 0, true)
on conflict (slug) do update set
  name = excluded.name,
  description = excluded.description,
  monthly_price = excluded.monthly_price,
  yearly_price = excluded.yearly_price,
  max_clients = excluded.max_clients,
  trial_days = excluded.trial_days,
  is_active = excluded.is_active;

create index if not exists idx_profiles_role on public.profiles(role);
create index if not exists idx_trainers_user_id on public.trainers(user_id);
create index if not exists idx_trainer_subscriptions_trainer_status on public.trainer_subscriptions(trainer_id, status);
create index if not exists idx_clients_trainer_status on public.clients(trainer_id, status);
create index if not exists idx_clients_user_id on public.clients(user_id);
create index if not exists idx_invite_codes_code_active on public.client_invite_codes(code, status);
create index if not exists idx_appointments_trainer_starts on public.appointments(trainer_id, starts_at);
create index if not exists idx_appointments_client_starts on public.appointments(client_id, starts_at);
create index if not exists idx_machines_trainer_group on public.machines(trainer_id, muscle_group);
create index if not exists idx_workout_plans_client_status on public.workout_plans(client_id, status);
create index if not exists idx_nutrition_plans_client_status on public.nutrition_plans(client_id, status);
create index if not exists idx_progress_entries_client_date on public.progress_entries(client_id, entry_date desc);
create index if not exists idx_progress_photos_entry on public.progress_photos(progress_entry_id);

create trigger set_profiles_updated_at before update on public.profiles for each row execute function public.set_updated_at();
create trigger set_trainers_updated_at before update on public.trainers for each row execute function public.set_updated_at();
create trigger set_trainer_subscriptions_updated_at before update on public.trainer_subscriptions for each row execute function public.set_updated_at();
create trigger set_clients_updated_at before update on public.clients for each row execute function public.set_updated_at();
create trigger set_appointments_updated_at before update on public.appointments for each row execute function public.set_updated_at();
create trigger set_machines_updated_at before update on public.machines for each row execute function public.set_updated_at();
create trigger set_workout_plans_updated_at before update on public.workout_plans for each row execute function public.set_updated_at();
create trigger set_workout_days_updated_at before update on public.workout_days for each row execute function public.set_updated_at();
create trigger set_exercises_updated_at before update on public.exercises for each row execute function public.set_updated_at();
create trigger set_nutrition_plans_updated_at before update on public.nutrition_plans for each row execute function public.set_updated_at();
create trigger set_meals_updated_at before update on public.meals for each row execute function public.set_updated_at();
create trigger set_progress_entries_updated_at before update on public.progress_entries for each row execute function public.set_updated_at();

create or replace function public.is_super_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists(select 1 from profiles where id = auth.uid() and role = 'super_admin');
$$;

create or replace function public.get_current_trainer_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select id from trainers where user_id = auth.uid() limit 1;
$$;

create or replace function public.get_current_client_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select id from clients where user_id = auth.uid() and status = 'active' limit 1;
$$;

create or replace function public.is_current_trainer(p_trainer_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select p_trainer_id = public.get_current_trainer_id() or public.is_super_admin();
$$;

create or replace function public.trainer_owns_client(p_trainer_id uuid, p_client_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists(
    select 1 from clients
    where id = p_client_id
      and trainer_id = p_trainer_id
      and (public.is_current_trainer(p_trainer_id) or user_id = auth.uid())
  );
$$;

create or replace function public.trainer_can_add_client(p_trainer_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  with active_subscription as (
    select sp.max_clients
    from trainer_subscriptions ts
    join subscription_plans sp on sp.id = ts.plan_id
    where ts.trainer_id = p_trainer_id
      and ts.status in ('trialing', 'active')
      and (ts.trial_ends_at is null or ts.trial_ends_at > now())
    order by ts.created_at desc
    limit 1
  ),
  client_count as (
    select count(*)::int as total
    from clients
    where trainer_id = p_trainer_id
      and status in ('pending_registration', 'active')
  )
  select exists(select 1 from active_subscription)
    and (
      (select max_clients from active_subscription) is null
      or (select total from client_count) < (select max_clients from active_subscription)
    );
$$;

create or replace function public.create_trainer_account(
  p_plan_slug text,
  p_first_name text,
  p_last_name text,
  p_business_name text,
  p_phone text default null
)
returns public.trainers
language plpgsql
security definer
set search_path = public
as $$
declare
  v_plan subscription_plans;
  v_trainer trainers;
  v_status text;
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  select * into v_plan
  from subscription_plans
  where slug = p_plan_slug and is_active = true;

  if v_plan.id is null then
    raise exception 'Invalid subscription plan';
  end if;

  insert into profiles (id, role, email, first_name, last_name, phone)
  values (
    auth.uid(),
    'trainer',
    coalesce((auth.jwt() ->> 'email'), ''),
    p_first_name,
    p_last_name,
    p_phone
  )
  on conflict (id) do update set
    role = 'trainer',
    first_name = excluded.first_name,
    last_name = excluded.last_name,
    phone = excluded.phone
  where profiles.id = auth.uid();

  v_status := case when v_plan.slug = 'trial_15' then 'trialing' else 'active' end;

  insert into trainers (user_id, business_name, phone, max_clients, status)
  values (auth.uid(), p_business_name, p_phone, v_plan.max_clients, case when v_status = 'trialing' then 'trialing' else 'active' end)
  returning * into v_trainer;

  insert into trainer_subscriptions (
    trainer_id,
    plan_id,
    status,
    starts_at,
    trial_ends_at,
    current_period_start,
    current_period_end,
    provider
  )
  values (
    v_trainer.id,
    v_plan.id,
    v_status,
    now(),
    case when v_plan.trial_days > 0 then now() + (v_plan.trial_days || ' days')::interval else null end,
    case when v_plan.trial_days = 0 then now() else null end,
    case when v_plan.trial_days = 0 then now() + interval '1 month' else null end,
    'manual_demo'
  );

  return v_trainer;
end;
$$;

create or replace function public.generate_client_invite_code(p_trainer_id uuid, p_client_id uuid)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_code text;
  v_token text;
  v_bytes bytea;
  v_alphabet text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  i int;
begin
  if not public.is_current_trainer(p_trainer_id) then
    raise exception 'Not allowed';
  end if;

  if not exists(select 1 from clients where id = p_client_id and trainer_id = p_trainer_id) then
    raise exception 'Client does not belong to trainer';
  end if;

  loop
    v_bytes := gen_random_bytes(8);
    v_token := '';
    for i in 0..7 loop
      v_token := v_token || substr(v_alphabet, (get_byte(v_bytes, i) % length(v_alphabet)) + 1, 1);
    end loop;
    v_code := 'PT-' || v_token;
    exit when not exists(select 1 from client_invite_codes where code = v_code);
  end loop;

  update client_invite_codes
  set status = 'revoked'
  where client_id = p_client_id
    and status = 'active';

  insert into client_invite_codes (trainer_id, client_id, code, status, expires_at)
  values (p_trainer_id, p_client_id, v_code, 'active', now() + interval '14 days');

  insert into app_audit_logs(actor_user_id, trainer_id, client_id, action, entity_type, entity_id)
  values(auth.uid(), p_trainer_id, p_client_id, 'invite_code_generated', 'client_invite_codes', null);

  return v_code;
end;
$$;

create or replace function public.redeem_client_invite_code(p_code text, p_email text)
returns public.clients
language plpgsql
security definer
set search_path = public
as $$
declare
  v_invite client_invite_codes;
  v_client clients;
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  select * into v_invite
  from client_invite_codes
  where code = upper(trim(p_code))
  for update;

  if v_invite.id is null then
    raise exception 'Invalid invite code';
  end if;

  if v_invite.status <> 'active' or v_invite.used_at is not null then
    raise exception 'Invite code already used or inactive';
  end if;

  if v_invite.expires_at <= now() then
    update client_invite_codes set status = 'expired' where id = v_invite.id;
    raise exception 'Invite code expired';
  end if;

  if exists(select 1 from clients where user_id = auth.uid()) then
    raise exception 'Authenticated user is already linked to a client';
  end if;

  insert into profiles (id, role, email, first_name, last_name)
  select auth.uid(), 'client', coalesce(nullif(p_email, ''), auth.jwt() ->> 'email', ''), c.first_name, c.last_name
  from clients c
  where c.id = v_invite.client_id
  on conflict (id) do update set role = 'client', email = excluded.email
  where profiles.id = auth.uid();

  update clients
  set user_id = auth.uid(),
      email = coalesce(nullif(p_email, ''), email),
      status = 'active',
      joined_at = now()
  where id = v_invite.client_id
    and trainer_id = v_invite.trainer_id
    and user_id is null
  returning * into v_client;

  if v_client.id is null then
    raise exception 'Client is already linked';
  end if;

  update client_invite_codes
  set status = 'used',
      used_at = now(),
      used_by_user_id = auth.uid()
  where id = v_invite.id;

  insert into app_audit_logs(actor_user_id, trainer_id, client_id, action, entity_type, entity_id)
  values(auth.uid(), v_invite.trainer_id, v_invite.client_id, 'invite_code_redeemed', 'clients', v_invite.client_id);

  return v_client;
end;
$$;

alter table public.profiles enable row level security;
alter table public.trainers enable row level security;
alter table public.subscription_plans enable row level security;
alter table public.trainer_subscriptions enable row level security;
alter table public.clients enable row level security;
alter table public.client_invite_codes enable row level security;
alter table public.appointments enable row level security;
alter table public.machines enable row level security;
alter table public.workout_plans enable row level security;
alter table public.workout_days enable row level security;
alter table public.exercises enable row level security;
alter table public.nutrition_plans enable row level security;
alter table public.meals enable row level security;
alter table public.meal_foods enable row level security;
alter table public.progress_entries enable row level security;
alter table public.progress_photos enable row level security;
alter table public.app_audit_logs enable row level security;

create policy "profiles_select_own" on public.profiles for select to authenticated using (id = auth.uid() or public.is_super_admin());
create policy "profiles_update_own" on public.profiles for update to authenticated using (id = auth.uid()) with check (id = auth.uid());
create policy "profiles_insert_own" on public.profiles for insert to authenticated with check (id = auth.uid());

create policy "plans_select_active" on public.subscription_plans for select to anon, authenticated using (is_active = true);

create policy "trainers_select_scoped" on public.trainers for select to authenticated using (
  public.is_current_trainer(id)
  or exists(select 1 from clients c where c.trainer_id = trainers.id and c.user_id = auth.uid())
);
create policy "trainers_update_own" on public.trainers for update to authenticated using (public.is_current_trainer(id)) with check (public.is_current_trainer(id));
create policy "trainers_insert_own" on public.trainers for insert to authenticated with check (user_id = auth.uid());

create policy "subscriptions_select_own" on public.trainer_subscriptions for select to authenticated using (public.is_current_trainer(trainer_id));
create policy "subscriptions_insert_own" on public.trainer_subscriptions for insert to authenticated with check (public.is_current_trainer(trainer_id));
create policy "subscriptions_update_own" on public.trainer_subscriptions for update to authenticated using (public.is_current_trainer(trainer_id)) with check (public.is_current_trainer(trainer_id));

create policy "clients_select_scoped" on public.clients for select to authenticated using (
  public.is_current_trainer(trainer_id) or user_id = auth.uid()
);
create policy "clients_insert_trainer" on public.clients for insert to authenticated with check (
  public.is_current_trainer(trainer_id) and public.trainer_can_add_client(trainer_id)
);
create policy "clients_update_scoped" on public.clients for update to authenticated using (
  public.is_current_trainer(trainer_id) or user_id = auth.uid()
) with check (
  public.is_current_trainer(trainer_id) or user_id = auth.uid()
);
create policy "clients_delete_trainer" on public.clients for delete to authenticated using (public.is_current_trainer(trainer_id));

create policy "invite_codes_select_trainer" on public.client_invite_codes for select to authenticated using (public.is_current_trainer(trainer_id));
create policy "invite_codes_insert_trainer" on public.client_invite_codes for insert to authenticated with check (public.is_current_trainer(trainer_id));
create policy "invite_codes_update_trainer" on public.client_invite_codes for update to authenticated using (public.is_current_trainer(trainer_id)) with check (public.is_current_trainer(trainer_id));

create policy "appointments_select_scoped" on public.appointments for select to authenticated using (
  public.is_current_trainer(trainer_id) or client_id = public.get_current_client_id()
);
create policy "appointments_trainer_write" on public.appointments for all to authenticated using (public.is_current_trainer(trainer_id)) with check (public.is_current_trainer(trainer_id));

create policy "machines_select_scoped" on public.machines for select to authenticated using (
  public.is_current_trainer(trainer_id)
  or exists(select 1 from clients c where c.trainer_id = machines.trainer_id and c.user_id = auth.uid())
);
create policy "machines_trainer_write" on public.machines for all to authenticated using (public.is_current_trainer(trainer_id)) with check (public.is_current_trainer(trainer_id));

create policy "workout_plans_select_scoped" on public.workout_plans for select to authenticated using (
  public.is_current_trainer(trainer_id) or client_id = public.get_current_client_id()
);
create policy "workout_plans_trainer_write" on public.workout_plans for all to authenticated using (public.is_current_trainer(trainer_id)) with check (public.is_current_trainer(trainer_id));

create policy "workout_days_select_scoped" on public.workout_days for select to authenticated using (
  exists(select 1 from workout_plans wp where wp.id = workout_days.workout_plan_id and (public.is_current_trainer(wp.trainer_id) or wp.client_id = public.get_current_client_id()))
);
create policy "workout_days_trainer_write" on public.workout_days for all to authenticated using (
  exists(select 1 from workout_plans wp where wp.id = workout_days.workout_plan_id and public.is_current_trainer(wp.trainer_id))
) with check (
  exists(select 1 from workout_plans wp where wp.id = workout_days.workout_plan_id and public.is_current_trainer(wp.trainer_id))
);

create policy "exercises_select_scoped" on public.exercises for select to authenticated using (
  exists(
    select 1 from workout_days wd
    join workout_plans wp on wp.id = wd.workout_plan_id
    where wd.id = exercises.workout_day_id
      and (public.is_current_trainer(wp.trainer_id) or wp.client_id = public.get_current_client_id())
  )
);
create policy "exercises_trainer_write" on public.exercises for all to authenticated using (
  exists(
    select 1 from workout_days wd
    join workout_plans wp on wp.id = wd.workout_plan_id
    where wd.id = exercises.workout_day_id and public.is_current_trainer(wp.trainer_id)
  )
) with check (
  exists(
    select 1 from workout_days wd
    join workout_plans wp on wp.id = wd.workout_plan_id
    where wd.id = exercises.workout_day_id and public.is_current_trainer(wp.trainer_id)
  )
);

create policy "nutrition_plans_select_scoped" on public.nutrition_plans for select to authenticated using (
  public.is_current_trainer(trainer_id) or client_id = public.get_current_client_id()
);
create policy "nutrition_plans_trainer_write" on public.nutrition_plans for all to authenticated using (public.is_current_trainer(trainer_id)) with check (public.is_current_trainer(trainer_id));

create policy "meals_select_scoped" on public.meals for select to authenticated using (
  exists(select 1 from nutrition_plans np where np.id = meals.nutrition_plan_id and (public.is_current_trainer(np.trainer_id) or np.client_id = public.get_current_client_id()))
);
create policy "meals_trainer_write" on public.meals for all to authenticated using (
  exists(select 1 from nutrition_plans np where np.id = meals.nutrition_plan_id and public.is_current_trainer(np.trainer_id))
) with check (
  exists(select 1 from nutrition_plans np where np.id = meals.nutrition_plan_id and public.is_current_trainer(np.trainer_id))
);

create policy "meal_foods_select_scoped" on public.meal_foods for select to authenticated using (
  exists(
    select 1 from meals m
    join nutrition_plans np on np.id = m.nutrition_plan_id
    where m.id = meal_foods.meal_id
      and (public.is_current_trainer(np.trainer_id) or np.client_id = public.get_current_client_id())
  )
);
create policy "meal_foods_trainer_write" on public.meal_foods for all to authenticated using (
  exists(
    select 1 from meals m
    join nutrition_plans np on np.id = m.nutrition_plan_id
    where m.id = meal_foods.meal_id and public.is_current_trainer(np.trainer_id)
  )
) with check (
  exists(
    select 1 from meals m
    join nutrition_plans np on np.id = m.nutrition_plan_id
    where m.id = meal_foods.meal_id and public.is_current_trainer(np.trainer_id)
  )
);

create policy "progress_entries_select_scoped" on public.progress_entries for select to authenticated using (
  public.is_current_trainer(trainer_id) or client_id = public.get_current_client_id()
);
create policy "progress_entries_insert_scoped" on public.progress_entries for insert to authenticated with check (
  public.is_current_trainer(trainer_id)
  or (client_id = public.get_current_client_id() and created_by_user_id = auth.uid())
);
create policy "progress_entries_update_scoped" on public.progress_entries for update to authenticated using (
  public.is_current_trainer(trainer_id) or (client_id = public.get_current_client_id() and created_by_user_id = auth.uid())
) with check (
  public.is_current_trainer(trainer_id) or (client_id = public.get_current_client_id() and created_by_user_id = auth.uid())
);

create policy "progress_photos_select_scoped" on public.progress_photos for select to authenticated using (
  public.is_current_trainer(trainer_id) or client_id = public.get_current_client_id()
);
create policy "progress_photos_insert_scoped" on public.progress_photos for insert to authenticated with check (
  public.is_current_trainer(trainer_id) or client_id = public.get_current_client_id()
);
create policy "progress_photos_delete_scoped" on public.progress_photos for delete to authenticated using (
  public.is_current_trainer(trainer_id) or client_id = public.get_current_client_id()
);

create policy "audit_logs_select_admin" on public.app_audit_logs for select to authenticated using (
  public.is_super_admin() or public.is_current_trainer(trainer_id) or client_id = public.get_current_client_id()
);

insert into storage.buckets (id, name, public)
values ('progress-photos', 'progress-photos', false)
on conflict (id) do update set public = false;

create policy "progress_photos_storage_select"
on storage.objects for select to authenticated
using (
  bucket_id = 'progress-photos'
  and (
    public.is_current_trainer(((storage.foldername(name))[1])::uuid)
    or ((storage.foldername(name))[2])::uuid = public.get_current_client_id()
  )
);

create policy "progress_photos_storage_insert_client_or_trainer"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'progress-photos'
  and (
    public.is_current_trainer(((storage.foldername(name))[1])::uuid)
    or ((storage.foldername(name))[2])::uuid = public.get_current_client_id()
  )
);

create policy "progress_photos_storage_delete_client_or_trainer"
on storage.objects for delete to authenticated
using (
  bucket_id = 'progress-photos'
  and (
    public.is_current_trainer(((storage.foldername(name))[1])::uuid)
    or ((storage.foldername(name))[2])::uuid = public.get_current_client_id()
  )
);

grant execute on function public.create_trainer_account(text, text, text, text, text) to authenticated;
grant execute on function public.generate_client_invite_code(uuid, uuid) to authenticated;
grant execute on function public.redeem_client_invite_code(text, text) to authenticated;
grant execute on function public.get_current_trainer_id() to authenticated;
grant execute on function public.get_current_client_id() to authenticated;
grant execute on function public.trainer_can_add_client(uuid) to authenticated;
