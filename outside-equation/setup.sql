-- Configure in a NEW dedicated Supabase project using SQL Editor.
-- Anonymous mothers can INSERT new messages and SELECT previously published messages.
-- They have no UPDATE or DELETE permissions.
create table if not exists public.mother_submissions (
  id uuid primary key default gen_random_uuid(),
  mother_name text not null check (char_length(trim(mother_name)) between 2 and 100),
  daughter_name text not null check (char_length(trim(daughter_name)) between 2 and 100),
  grade text not null check (grade in ('العاشر','الحادي عشر','الثاني عشر')),
  topic text not null check (topic in ('خارج المعادلة','طاقة لا تنفد','إلى ابنتي','اتزان الحياة','قانون الأمومة')),
  body text not null check (char_length(trim(body)) between 20 and 2500),
  status text not null default 'approved' check (status='approved'),
  created_at timestamptz not null default now()
);
alter table public.mother_submissions enable row level security;
revoke all on public.mother_submissions from anon,authenticated;
grant select, insert(mother_name,daughter_name,grade,topic,body) on public.mother_submissions to anon;
create policy "Mothers can add messages" on public.mother_submissions for insert to anon with check (status='approved');
create policy "Everyone can see published messages" on public.mother_submissions for select to anon using (status='approved');
create index if not exists mother_submissions_newest on public.mother_submissions(created_at desc,id desc);
-- Maintain backups, content-moderation and rate-limits; database administrators retain removal ability for privacy requests.
