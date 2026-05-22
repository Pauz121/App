create table if not exists public.muscle_groups (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  slug text not null unique,
  description text,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.machine_catalog (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  muscle_group text not null,
  category text,
  description text,
  usage_notes text,
  difficulty text,
  is_bodyweight boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.exercise_catalog (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  muscle_group text not null,
  secondary_muscles text[],
  equipment text,
  difficulty text,
  movement_type text,
  description text,
  execution_notes text,
  common_mistakes text,
  default_sets integer,
  default_reps text,
  default_rest_seconds integer,
  created_at timestamptz not null default now()
);

create table if not exists public.food_catalog (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  category text not null,
  calories_per_100g integer,
  proteins_per_100g numeric(7,2),
  carbs_per_100g numeric(7,2),
  fats_per_100g numeric(7,2),
  unit text not null default 'g',
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.meal_templates (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  meal_type text not null,
  goal text,
  description text,
  created_at timestamptz not null default now()
);

create table if not exists public.meal_template_foods (
  id uuid primary key default gen_random_uuid(),
  meal_template_id uuid not null references public.meal_templates(id) on delete cascade,
  food_catalog_id uuid not null references public.food_catalog(id) on delete restrict,
  quantity text not null,
  notes text,
  created_at timestamptz not null default now(),
  unique (meal_template_id, food_catalog_id)
);

create table if not exists public.workout_templates (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  goal text,
  level text,
  days_per_week integer,
  description text,
  created_at timestamptz not null default now()
);

create table if not exists public.workout_template_days (
  id uuid primary key default gen_random_uuid(),
  workout_template_id uuid not null references public.workout_templates(id) on delete cascade,
  name text not null,
  day_order integer not null,
  notes text,
  created_at timestamptz not null default now(),
  unique (workout_template_id, day_order)
);

create table if not exists public.workout_template_exercises (
  id uuid primary key default gen_random_uuid(),
  workout_template_day_id uuid not null references public.workout_template_days(id) on delete cascade,
  exercise_catalog_id uuid not null references public.exercise_catalog(id) on delete restrict,
  exercise_order integer not null,
  sets integer not null,
  reps text not null,
  rest_seconds integer,
  suggested_load text,
  notes text,
  created_at timestamptz not null default now(),
  unique (workout_template_day_id, exercise_order)
);

create index if not exists idx_machine_catalog_muscle_group on public.machine_catalog(muscle_group);
create index if not exists idx_exercise_catalog_muscle_group on public.exercise_catalog(muscle_group);
create index if not exists idx_food_catalog_category on public.food_catalog(category);
create index if not exists idx_meal_templates_type_goal on public.meal_templates(meal_type, goal);
create index if not exists idx_workout_templates_goal_level on public.workout_templates(goal, level);

alter table public.muscle_groups enable row level security;
alter table public.machine_catalog enable row level security;
alter table public.exercise_catalog enable row level security;
alter table public.food_catalog enable row level security;
alter table public.meal_templates enable row level security;
alter table public.meal_template_foods enable row level security;
alter table public.workout_templates enable row level security;
alter table public.workout_template_days enable row level security;
alter table public.workout_template_exercises enable row level security;

drop policy if exists "catalog_muscle_groups_select_authenticated" on public.muscle_groups;
drop policy if exists "catalog_machine_select_authenticated" on public.machine_catalog;
drop policy if exists "catalog_exercise_select_authenticated" on public.exercise_catalog;
drop policy if exists "catalog_food_select_authenticated" on public.food_catalog;
drop policy if exists "catalog_meal_templates_select_authenticated" on public.meal_templates;
drop policy if exists "catalog_meal_template_foods_select_authenticated" on public.meal_template_foods;
drop policy if exists "catalog_workout_templates_select_authenticated" on public.workout_templates;
drop policy if exists "catalog_workout_template_days_select_authenticated" on public.workout_template_days;
drop policy if exists "catalog_workout_template_exercises_select_authenticated" on public.workout_template_exercises;
drop policy if exists "catalog_muscle_groups_admin_write" on public.muscle_groups;
drop policy if exists "catalog_machine_admin_write" on public.machine_catalog;
drop policy if exists "catalog_exercise_admin_write" on public.exercise_catalog;
drop policy if exists "catalog_food_admin_write" on public.food_catalog;
drop policy if exists "catalog_meal_templates_admin_write" on public.meal_templates;
drop policy if exists "catalog_meal_template_foods_admin_write" on public.meal_template_foods;
drop policy if exists "catalog_workout_templates_admin_write" on public.workout_templates;
drop policy if exists "catalog_workout_template_days_admin_write" on public.workout_template_days;
drop policy if exists "catalog_workout_template_exercises_admin_write" on public.workout_template_exercises;

create policy "catalog_muscle_groups_select_authenticated" on public.muscle_groups for select to authenticated using (true);
create policy "catalog_machine_select_authenticated" on public.machine_catalog for select to authenticated using (true);
create policy "catalog_exercise_select_authenticated" on public.exercise_catalog for select to authenticated using (true);
create policy "catalog_food_select_authenticated" on public.food_catalog for select to authenticated using (true);
create policy "catalog_meal_templates_select_authenticated" on public.meal_templates for select to authenticated using (true);
create policy "catalog_meal_template_foods_select_authenticated" on public.meal_template_foods for select to authenticated using (true);
create policy "catalog_workout_templates_select_authenticated" on public.workout_templates for select to authenticated using (true);
create policy "catalog_workout_template_days_select_authenticated" on public.workout_template_days for select to authenticated using (true);
create policy "catalog_workout_template_exercises_select_authenticated" on public.workout_template_exercises for select to authenticated using (true);

create policy "catalog_muscle_groups_admin_write" on public.muscle_groups for all to authenticated using (public.is_super_admin()) with check (public.is_super_admin());
create policy "catalog_machine_admin_write" on public.machine_catalog for all to authenticated using (public.is_super_admin()) with check (public.is_super_admin());
create policy "catalog_exercise_admin_write" on public.exercise_catalog for all to authenticated using (public.is_super_admin()) with check (public.is_super_admin());
create policy "catalog_food_admin_write" on public.food_catalog for all to authenticated using (public.is_super_admin()) with check (public.is_super_admin());
create policy "catalog_meal_templates_admin_write" on public.meal_templates for all to authenticated using (public.is_super_admin()) with check (public.is_super_admin());
create policy "catalog_meal_template_foods_admin_write" on public.meal_template_foods for all to authenticated using (public.is_super_admin()) with check (public.is_super_admin());
create policy "catalog_workout_templates_admin_write" on public.workout_templates for all to authenticated using (public.is_super_admin()) with check (public.is_super_admin());
create policy "catalog_workout_template_days_admin_write" on public.workout_template_days for all to authenticated using (public.is_super_admin()) with check (public.is_super_admin());
create policy "catalog_workout_template_exercises_admin_write" on public.workout_template_exercises for all to authenticated using (public.is_super_admin()) with check (public.is_super_admin());
