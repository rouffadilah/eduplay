-- EDUPLAY foundation schema for Supabase (PostgreSQL)
-- Apply in Supabase SQL Editor or via Supabase CLI.
-- IMPORTANT: this migration creates the data foundation only. It does not connect the
-- static GitHub Pages frontend to Supabase or configure authentication for the app.

create extension if not exists pgcrypto;

do $$ begin
  create type public.membership_role as enum ('student','teacher','school_admin','platform_admin');
exception when duplicate_object then null; end $$;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default '',
  email text,
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.schools (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  code text unique,
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.school_memberships (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  role public.membership_role not null default 'student',
  status text not null default 'active' check (status in ('invited','active','suspended')),
  created_at timestamptz not null default now(),
  unique (school_id, user_id)
);

create table if not exists public.classes (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete cascade,
  name text not null,
  grade_level text,
  academic_year text,
  homeroom_teacher_id uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  unique (school_id, name, academic_year)
);

create table if not exists public.class_teachers (
  class_id uuid not null references public.classes(id) on delete cascade,
  teacher_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (class_id, teacher_id)
);

create table if not exists public.enrollments (
  class_id uuid not null references public.classes(id) on delete cascade,
  student_id uuid not null references public.profiles(id) on delete cascade,
  status text not null default 'active' check (status in ('active','inactive')),
  enrolled_at timestamptz not null default now(),
  primary key (class_id, student_id)
);

create table if not exists public.subjects (
  id uuid primary key default gen_random_uuid(),
  school_id uuid references public.schools(id) on delete cascade,
  name text not null,
  code text,
  created_at timestamptz not null default now()
);

create table if not exists public.courses (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete cascade,
  subject_id uuid references public.subjects(id) on delete set null,
  class_id uuid references public.classes(id) on delete set null,
  title text not null,
  description text,
  created_by uuid references public.profiles(id) on delete set null,
  status text not null default 'draft' check (status in ('draft','published','archived')),
  created_at timestamptz not null default now()
);

create table if not exists public.lessons (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references public.courses(id) on delete cascade,
  title text not null,
  content jsonb not null default '{}'::jsonb,
  position integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.assignments (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references public.courses(id) on delete cascade,
  title text not null,
  instructions text,
  due_at timestamptz,
  max_score numeric(7,2) not null default 100,
  status text not null default 'draft' check (status in ('draft','published','closed')),
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.questions (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete cascade,
  subject_id uuid references public.subjects(id) on delete set null,
  created_by uuid references public.profiles(id) on delete set null,
  question_type text not null default 'multiple_choice',
  prompt text not null,
  options jsonb not null default '[]'::jsonb,
  answer_key jsonb not null default '{}'::jsonb,
  explanation text,
  difficulty text check (difficulty in ('easy','medium','hard')),
  tags text[] not null default '{}',
  created_at timestamptz not null default now()
);

create table if not exists public.assessments (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete cascade,
  class_id uuid references public.classes(id) on delete set null,
  course_id uuid references public.courses(id) on delete set null,
  title text not null,
  instructions text,
  opens_at timestamptz,
  closes_at timestamptz,
  duration_minutes integer check (duration_minutes is null or duration_minutes > 0),
  shuffle_questions boolean not null default true,
  status text not null default 'draft' check (status in ('draft','published','closed')),
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.assessment_questions (
  assessment_id uuid not null references public.assessments(id) on delete cascade,
  question_id uuid not null references public.questions(id) on delete cascade,
  position integer not null default 0,
  points numeric(7,2) not null default 1,
  primary key (assessment_id, question_id)
);

create table if not exists public.assessment_attempts (
  id uuid primary key default gen_random_uuid(),
  assessment_id uuid not null references public.assessments(id) on delete cascade,
  student_id uuid not null references public.profiles(id) on delete cascade,
  started_at timestamptz not null default now(),
  submitted_at timestamptz,
  score numeric(7,2),
  status text not null default 'in_progress' check (status in ('in_progress','submitted','graded')),
  unique (assessment_id, student_id, started_at)
);

create table if not exists public.assessment_answers (
  id uuid primary key default gen_random_uuid(),
  attempt_id uuid not null references public.assessment_attempts(id) on delete cascade,
  question_id uuid not null references public.questions(id) on delete cascade,
  response jsonb not null default '{}'::jsonb,
  awarded_points numeric(7,2),
  feedback text,
  answered_at timestamptz not null default now(),
  unique (attempt_id, question_id)
);

create table if not exists public.game_progress (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.profiles(id) on delete cascade,
  game_key text not null default 'eduplay-3d',
  progress jsonb not null default '{}'::jsonb,
  xp integer not null default 0 check (xp >= 0),
  coins integer not null default 0 check (coins >= 0),
  completed_missions integer not null default 0 check (completed_missions >= 0),
  updated_at timestamptz not null default now(),
  unique (student_id, game_key)
);

create table if not exists public.activity_events (
  id bigint generated always as identity primary key,
  school_id uuid references public.schools(id) on delete set null,
  user_id uuid references public.profiles(id) on delete set null,
  event_type text not null,
  entity_type text,
  entity_id uuid,
  metadata jsonb not null default '{}'::jsonb,
  occurred_at timestamptz not null default now()
);

create index if not exists idx_memberships_user on public.school_memberships(user_id, school_id);
create index if not exists idx_classes_school on public.classes(school_id);
create index if not exists idx_enrollments_student on public.enrollments(student_id);
create index if not exists idx_courses_class on public.courses(class_id);
create index if not exists idx_assessments_class on public.assessments(class_id, status);
create index if not exists idx_attempts_student on public.assessment_attempts(student_id, assessment_id);
create index if not exists idx_events_school_time on public.activity_events(school_id, occurred_at desc);

-- Profile creation is triggered by Supabase Auth. Role assignment is deliberately NOT
-- accepted from user metadata; privileged roles must be assigned by a trusted admin.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, display_name, email)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'display_name', ''), new.email)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

create or replace function public.is_school_member(target_school uuid)
returns boolean language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.school_memberships m
    where m.school_id = target_school and m.user_id = (select auth.uid()) and m.status = 'active'
  );
$$;

create or replace function public.has_school_role(target_school uuid, allowed_roles public.membership_role[])
returns boolean language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.school_memberships m
    where m.school_id = target_school and m.user_id = (select auth.uid())
      and m.status = 'active' and m.role = any(allowed_roles)
  );
$$;

create or replace function public.teaches_class(target_class uuid)
returns boolean language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.class_teachers ct
    where ct.class_id = target_class and ct.teacher_id = (select auth.uid())
  ) or exists (
    select 1 from public.classes c
    join public.school_memberships m on m.school_id = c.school_id
    where c.id = target_class and c.homeroom_teacher_id = (select auth.uid())
      and m.user_id = (select auth.uid()) and m.status = 'active'
      and m.role in ('teacher','school_admin','platform_admin')
  );
$$;

create or replace function public.is_enrolled(target_class uuid)
returns boolean language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.enrollments e
    where e.class_id = target_class and e.student_id = (select auth.uid()) and e.status = 'active'
  );
$$;

-- Enable RLS on every application table.
alter table public.profiles enable row level security;
alter table public.schools enable row level security;
alter table public.school_memberships enable row level security;
alter table public.classes enable row level security;
alter table public.class_teachers enable row level security;
alter table public.enrollments enable row level security;
alter table public.subjects enable row level security;
alter table public.courses enable row level security;
alter table public.lessons enable row level security;
alter table public.assignments enable row level security;
alter table public.questions enable row level security;
alter table public.assessments enable row level security;
alter table public.assessment_questions enable row level security;
alter table public.assessment_attempts enable row level security;
alter table public.assessment_answers enable row level security;
alter table public.game_progress enable row level security;
alter table public.activity_events enable row level security;

-- Profiles: users can read/update only their own profile.
drop policy if exists "profile read self" on public.profiles;
create policy "profile read self" on public.profiles for select to authenticated using (id = (select auth.uid()));
drop policy if exists "profile update self" on public.profiles;
create policy "profile update self" on public.profiles for update to authenticated using (id = (select auth.uid())) with check (id = (select auth.uid()));

-- School and membership visibility is scoped to active members.
drop policy if exists "school read member" on public.schools;
create policy "school read member" on public.schools for select to authenticated using (public.is_school_member(id));
drop policy if exists "membership read own or school admin" on public.school_memberships;
create policy "membership read own or school admin" on public.school_memberships for select to authenticated
using (user_id = (select auth.uid()) or public.has_school_role(school_id, array['school_admin','platform_admin']::public.membership_role[]));

drop policy if exists "membership admin manage" on public.school_memberships;
create policy "membership admin manage" on public.school_memberships for all to authenticated
using (public.has_school_role(school_id, array['school_admin','platform_admin']::public.membership_role[]))
with check (public.has_school_role(school_id, array['school_admin','platform_admin']::public.membership_role[]));

drop policy if exists "classes read school member" on public.classes;
create policy "classes read school member" on public.classes for select to authenticated using (public.is_school_member(school_id));
drop policy if exists "classes admin manage" on public.classes;
create policy "classes admin manage" on public.classes for all to authenticated
using (public.has_school_role(school_id, array['school_admin','platform_admin']::public.membership_role[]))
with check (public.has_school_role(school_id, array['school_admin','platform_admin']::public.membership_role[]));

drop policy if exists "class teachers read member" on public.class_teachers;
create policy "class teachers read member" on public.class_teachers for select to authenticated
using (exists (select 1 from public.classes c where c.id = class_id and public.is_school_member(c.school_id)));
drop policy if exists "class teachers admin manage" on public.class_teachers;
create policy "class teachers admin manage" on public.class_teachers for all to authenticated
using (exists (select 1 from public.classes c where c.id = class_id and public.has_school_role(c.school_id, array['school_admin','platform_admin']::public.membership_role[])))
with check (exists (select 1 from public.classes c where c.id = class_id and public.has_school_role(c.school_id, array['school_admin','platform_admin']::public.membership_role[])));

drop policy if exists "enrollment read self or teacher" on public.enrollments;
create policy "enrollment read self or teacher" on public.enrollments for select to authenticated
using (student_id = (select auth.uid()) or public.teaches_class(class_id));
drop policy if exists "enrollment admin manage" on public.enrollments;
create policy "enrollment admin manage" on public.enrollments for all to authenticated
using (exists (select 1 from public.classes c where c.id = class_id and public.has_school_role(c.school_id, array['school_admin','platform_admin']::public.membership_role[])))
with check (exists (select 1 from public.classes c where c.id = class_id and public.has_school_role(c.school_id, array['school_admin','platform_admin']::public.membership_role[])));

drop policy if exists "subjects read member" on public.subjects;
create policy "subjects read member" on public.subjects for select to authenticated
using (school_id is null or public.is_school_member(school_id));
drop policy if exists "subjects admin manage" on public.subjects;
create policy "subjects admin manage" on public.subjects for all to authenticated
using (school_id is not null and public.has_school_role(school_id, array['school_admin','platform_admin']::public.membership_role[]))
with check (school_id is not null and public.has_school_role(school_id, array['school_admin','platform_admin']::public.membership_role[]));

drop policy if exists "courses read member" on public.courses;
create policy "courses read member" on public.courses for select to authenticated
using (public.is_school_member(school_id) and (status = 'published' or created_by = (select auth.uid()) or public.has_school_role(school_id, array['school_admin','platform_admin']::public.membership_role[])));
drop policy if exists "courses teacher manage" on public.courses;
create policy "courses teacher manage" on public.courses for all to authenticated
using (public.has_school_role(school_id, array['teacher','school_admin','platform_admin']::public.membership_role[]))
with check (public.has_school_role(school_id, array['teacher','school_admin','platform_admin']::public.membership_role[]));

drop policy if exists "lessons read published course" on public.lessons;
create policy "lessons read published course" on public.lessons for select to authenticated
using (exists (select 1 from public.courses c where c.id = course_id and public.is_school_member(c.school_id) and (c.status = 'published' or c.created_by = (select auth.uid()))));
drop policy if exists "lessons teacher manage" on public.lessons;
create policy "lessons teacher manage" on public.lessons for all to authenticated
using (exists (select 1 from public.courses c where c.id = course_id and public.has_school_role(c.school_id, array['teacher','school_admin','platform_admin']::public.membership_role[])))
with check (exists (select 1 from public.courses c where c.id = course_id and public.has_school_role(c.school_id, array['teacher','school_admin','platform_admin']::public.membership_role[])));

drop policy if exists "assignments read published course" on public.assignments;
create policy "assignments read published course" on public.assignments for select to authenticated
using (exists (select 1 from public.courses c where c.id = course_id and public.is_school_member(c.school_id) and (status = 'published' or created_by = (select auth.uid()))));
drop policy if exists "assignments teacher manage" on public.assignments;
create policy "assignments teacher manage" on public.assignments for all to authenticated
using (exists (select 1 from public.courses c where c.id = course_id and public.has_school_role(c.school_id, array['teacher','school_admin','platform_admin']::public.membership_role[])))
with check (exists (select 1 from public.courses c where c.id = course_id and public.has_school_role(c.school_id, array['teacher','school_admin','platform_admin']::public.membership_role[])));

-- Answer keys stay hidden from students: only teachers/admins can read question bank rows.
drop policy if exists "questions teacher read" on public.questions;
create policy "questions teacher read" on public.questions for select to authenticated
using (public.has_school_role(school_id, array['teacher','school_admin','platform_admin']::public.membership_role[]));
drop policy if exists "questions teacher manage" on public.questions;
create policy "questions teacher manage" on public.questions for all to authenticated
using (public.has_school_role(school_id, array['teacher','school_admin','platform_admin']::public.membership_role[]))
with check (public.has_school_role(school_id, array['teacher','school_admin','platform_admin']::public.membership_role[]));

drop policy if exists "assessments read permitted" on public.assessments;
create policy "assessments read permitted" on public.assessments for select to authenticated
using (
  public.has_school_role(school_id, array['teacher','school_admin','platform_admin']::public.membership_role[])
  or (status = 'published' and public.is_school_member(school_id) and (class_id is null or public.is_enrolled(class_id)))
);
drop policy if exists "assessments teacher manage" on public.assessments;
create policy "assessments teacher manage" on public.assessments for all to authenticated
using (public.has_school_role(school_id, array['teacher','school_admin','platform_admin']::public.membership_role[]))
with check (public.has_school_role(school_id, array['teacher','school_admin','platform_admin']::public.membership_role[]));

-- Do not expose answer_key in a client-readable table. assessment_questions is metadata only;
-- question content for a live test must be served by a trusted Edge Function that strips answer_key.
drop policy if exists "assessment question metadata read" on public.assessment_questions;
create policy "assessment question metadata read" on public.assessment_questions for select to authenticated
using (exists (select 1 from public.assessments a where a.id = assessment_id and a.status = 'published'
  and public.is_school_member(a.school_id) and (a.class_id is null or public.is_enrolled(a.class_id))));
drop policy if exists "assessment question teacher manage" on public.assessment_questions;
create policy "assessment question teacher manage" on public.assessment_questions for all to authenticated
using (exists (select 1 from public.assessments a where a.id = assessment_id and public.has_school_role(a.school_id, array['teacher','school_admin','platform_admin']::public.membership_role[])))
with check (exists (select 1 from public.assessments a where a.id = assessment_id and public.has_school_role(a.school_id, array['teacher','school_admin','platform_admin']::public.membership_role[])));

drop policy if exists "attempt read self or teacher" on public.assessment_attempts;
create policy "attempt read self or teacher" on public.assessment_attempts for select to authenticated
using (student_id = (select auth.uid()) or exists (select 1 from public.assessments a where a.id = assessment_id and public.has_school_role(a.school_id, array['teacher','school_admin','platform_admin']::public.membership_role[])));
drop policy if exists "attempt student create own" on public.assessment_attempts;
create policy "attempt student create own" on public.assessment_attempts for insert to authenticated
with check (student_id = (select auth.uid()) and exists (select 1 from public.assessments a where a.id = assessment_id and a.status = 'published' and public.is_school_member(a.school_id) and (a.class_id is null or public.is_enrolled(a.class_id))));
drop policy if exists "attempt student update own in progress" on public.assessment_attempts;
create policy "attempt student update own in progress" on public.assessment_attempts for update to authenticated
using (student_id = (select auth.uid()) and status = 'in_progress')
with check (student_id = (select auth.uid()));

drop policy if exists "answers read self or teacher" on public.assessment_answers;
create policy "answers read self or teacher" on public.assessment_answers for select to authenticated
using (exists (select 1 from public.assessment_attempts t where t.id = attempt_id and (t.student_id = (select auth.uid()) or exists (select 1 from public.assessments a where a.id = t.assessment_id and public.has_school_role(a.school_id, array['teacher','school_admin','platform_admin']::public.membership_role[])))));
drop policy if exists "answers student manage own attempt" on public.assessment_answers;
create policy "answers student manage own attempt" on public.assessment_answers for all to authenticated
using (exists (select 1 from public.assessment_attempts t where t.id = attempt_id and t.student_id = (select auth.uid()) and t.status = 'in_progress'))
with check (exists (select 1 from public.assessment_attempts t where t.id = attempt_id and t.student_id = (select auth.uid()) and t.status = 'in_progress'));

drop policy if exists "game progress own" on public.game_progress;
create policy "game progress own" on public.game_progress for select to authenticated using (student_id = (select auth.uid()));
drop policy if exists "game progress write own" on public.game_progress;
create policy "game progress write own" on public.game_progress for insert to authenticated with check (student_id = (select auth.uid()));
drop policy if exists "game progress update own" on public.game_progress;
create policy "game progress update own" on public.game_progress for update to authenticated using (student_id = (select auth.uid())) with check (student_id = (select auth.uid()));

drop policy if exists "activity read self or admin" on public.activity_events;
create policy "activity read self or admin" on public.activity_events for select to authenticated
using (user_id = (select auth.uid()) or (school_id is not null and public.has_school_role(school_id, array['teacher','school_admin','platform_admin']::public.membership_role[])));
drop policy if exists "activity insert self" on public.activity_events;
create policy "activity insert self" on public.activity_events for insert to authenticated
with check (user_id = (select auth.uid()) and (school_id is null or public.is_school_member(school_id)));

-- No anonymous/public policies are created. Keep the Supabase service_role key server-side only.
