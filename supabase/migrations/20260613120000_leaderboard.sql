create table public.athletes (
  id bigint generated always as identity primary key,
  name text not null,
  score integer not null check (score >= 0),
  weekly_gain_pct numeric(5, 2) not null default 0,
  is_you boolean not null default false,
  created_at timestamptz not null default now()
);

insert into public.athletes (name, score, weekly_gain_pct, is_you) values
  ('Kasia M.', 2840, 12.5, false),
  ('Ty', 2710, 8.3, true),
  ('Marek W.', 2650, 5.1, false),
  ('Ola K.', 2480, 15.2, false),
  ('Piotr L.', 2310, 3.8, false),
  ('Ania S.', 2190, 9.7, false);

alter table public.athletes enable row level security;

create policy "leaderboard is readable by everyone"
  on public.athletes
  for select
  using (true);
