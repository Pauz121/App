-- Daily engagement, HealthKit summaries and trainer insights.
-- HealthKit raw data is not stored: only daily step summaries are persisted after user consent.

create table if not exists public.daily_checkins (
  id uuid primary key default gen_random_uuid(),
  trainer_id uuid not null references public.trainers(id) on delete cascade,
  client_id uuid not null references public.clients(id) on delete cascade,
  checkin_date date not null,
  energy_level integer not null check (energy_level between 1 and 5),
  sleep_quality integer not null check (sleep_quality between 1 and 5),
  hunger_level integer not null check (hunger_level between 1 and 5),
  stress_level integer not null check (stress_level between 1 and 5),
  muscle_soreness boolean not null default false,
  diet_adherence text not null check (diet_adherence in ('yes', 'partial', 'no')),
  workout_completed boolean not null default false,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (client_id, checkin_date)
);

create table if not exists public.daily_goals (
  id uuid primary key default gen_random_uuid(),
  trainer_id uuid not null references public.trainers(id) on delete cascade,
  client_id uuid not null references public.clients(id) on delete cascade,
  goal_date date not null default current_date,
  goal_type text not null check (goal_type in ('steps', 'workout', 'check_in', 'weight', 'progress_photo')),
  title text not null,
  target_value numeric,
  current_value numeric,
  unit text,
  status text not null default 'pending' check (status in ('pending', 'completed', 'skipped')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.client_activity_summaries (
  id uuid primary key default gen_random_uuid(),
  trainer_id uuid not null references public.trainers(id) on delete cascade,
  client_id uuid not null references public.clients(id) on delete cascade,
  summary_date date not null default current_date,
  steps integer check (steps is null or steps >= 0),
  steps_goal integer check (steps_goal is null or steps_goal > 0),
  source text not null default 'healthkit',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (client_id, summary_date)
);

create table if not exists public.client_streaks (
  id uuid primary key default gen_random_uuid(),
  trainer_id uuid not null references public.trainers(id) on delete cascade,
  client_id uuid not null references public.clients(id) on delete cascade,
  streak_type text not null check (streak_type in ('check_in', 'steps', 'workout_week')),
  current_count integer not null default 0 check (current_count >= 0),
  best_count integer not null default 0 check (best_count >= 0),
  last_completed_at date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (client_id, streak_type)
);

create index if not exists idx_daily_checkins_trainer_date on public.daily_checkins(trainer_id, checkin_date desc);
create index if not exists idx_daily_checkins_client_date on public.daily_checkins(client_id, checkin_date desc);
create index if not exists idx_daily_goals_client_date on public.daily_goals(client_id, goal_date desc);
create index if not exists idx_daily_goals_trainer_date on public.daily_goals(trainer_id, goal_date desc);
create index if not exists idx_activity_summaries_client_date on public.client_activity_summaries(client_id, summary_date desc);
create index if not exists idx_activity_summaries_trainer_date on public.client_activity_summaries(trainer_id, summary_date desc);
create index if not exists idx_client_streaks_client_type on public.client_streaks(client_id, streak_type);
create index if not exists idx_client_streaks_trainer_type on public.client_streaks(trainer_id, streak_type);

drop trigger if exists set_daily_checkins_updated_at on public.daily_checkins;
create trigger set_daily_checkins_updated_at before update on public.daily_checkins for each row execute function public.set_updated_at();

drop trigger if exists set_daily_goals_updated_at on public.daily_goals;
create trigger set_daily_goals_updated_at before update on public.daily_goals for each row execute function public.set_updated_at();

drop trigger if exists set_activity_summaries_updated_at on public.client_activity_summaries;
create trigger set_activity_summaries_updated_at before update on public.client_activity_summaries for each row execute function public.set_updated_at();

drop trigger if exists set_client_streaks_updated_at on public.client_streaks;
create trigger set_client_streaks_updated_at before update on public.client_streaks for each row execute function public.set_updated_at();

alter table public.daily_checkins enable row level security;
alter table public.daily_goals enable row level security;
alter table public.client_activity_summaries enable row level security;
alter table public.client_streaks enable row level security;

create policy "daily_checkins_select_scoped"
on public.daily_checkins for select to authenticated
using (
  public.is_current_trainer(trainer_id)
  or client_id = public.get_current_client_id()
);

create policy "daily_checkins_client_insert_own"
on public.daily_checkins for insert to authenticated
with check (
  client_id = public.get_current_client_id()
  and exists(select 1 from public.clients c where c.id = client_id and c.trainer_id = trainer_id and c.user_id = auth.uid())
);

create policy "daily_checkins_client_update_own"
on public.daily_checkins for update to authenticated
using (client_id = public.get_current_client_id())
with check (
  client_id = public.get_current_client_id()
  and exists(select 1 from public.clients c where c.id = client_id and c.trainer_id = trainer_id and c.user_id = auth.uid())
);

create policy "daily_goals_select_scoped"
on public.daily_goals for select to authenticated
using (
  public.is_current_trainer(trainer_id)
  or client_id = public.get_current_client_id()
);

create policy "daily_goals_trainer_insert"
on public.daily_goals for insert to authenticated
with check (
  public.is_current_trainer(trainer_id)
  and exists(select 1 from public.clients c where c.id = client_id and c.trainer_id = trainer_id)
);

create policy "daily_goals_trainer_update"
on public.daily_goals for update to authenticated
using (public.is_current_trainer(trainer_id))
with check (
  public.is_current_trainer(trainer_id)
  and exists(select 1 from public.clients c where c.id = client_id and c.trainer_id = trainer_id)
);

create policy "daily_goals_trainer_delete"
on public.daily_goals for delete to authenticated
using (public.is_current_trainer(trainer_id));

create policy "activity_summaries_select_scoped"
on public.client_activity_summaries for select to authenticated
using (
  public.is_current_trainer(trainer_id)
  or client_id = public.get_current_client_id()
);

create policy "activity_summaries_client_insert_own"
on public.client_activity_summaries for insert to authenticated
with check (
  client_id = public.get_current_client_id()
  and exists(select 1 from public.clients c where c.id = client_id and c.trainer_id = trainer_id and c.user_id = auth.uid())
);

create policy "activity_summaries_client_update_own"
on public.client_activity_summaries for update to authenticated
using (client_id = public.get_current_client_id())
with check (
  client_id = public.get_current_client_id()
  and exists(select 1 from public.clients c where c.id = client_id and c.trainer_id = trainer_id and c.user_id = auth.uid())
);

create policy "client_streaks_select_scoped"
on public.client_streaks for select to authenticated
using (
  public.is_current_trainer(trainer_id)
  or client_id = public.get_current_client_id()
);

create policy "client_streaks_client_insert_own"
on public.client_streaks for insert to authenticated
with check (
  client_id = public.get_current_client_id()
  and exists(select 1 from public.clients c where c.id = client_id and c.trainer_id = trainer_id and c.user_id = auth.uid())
);

create policy "client_streaks_client_update_own"
on public.client_streaks for update to authenticated
using (client_id = public.get_current_client_id())
with check (
  client_id = public.get_current_client_id()
  and exists(select 1 from public.clients c where c.id = client_id and c.trainer_id = trainer_id and c.user_id = auth.uid())
);

grant select, insert, update, delete on public.daily_checkins to authenticated;
grant select, insert, update, delete on public.daily_goals to authenticated;
grant select, insert, update, delete on public.client_activity_summaries to authenticated;
grant select, insert, update, delete on public.client_streaks to authenticated;
