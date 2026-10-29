-- 24h chez Renaissance : la table des clés
-- À coller dans Supabase > SQL Editor > New query, puis « Run ».

create table if not exists public.cles (
  id          bigint generated always as identity primary key,
  created_at  timestamptz not null default now(),
  prenom      text not null check (char_length(prenom) between 1 and 24),
  email       text not null check (char_length(email) <= 254 and email ~* '^[^@\s]+@[^@\s]+\.[^@\s]{2,}$'),
  envies      smallint[] not null default '{}',   -- 1 Art, 2 Goût, 3 Son, 4 Bien-être
  numero      text not null,                      -- N° affiché sur la clé
  niveau      text not null default 'Voisin' check (niveau in ('Voisin', 'Habitué', 'Initié')),
  source      text not null default 'direct'      -- quelle affiche a été scannée (?src=...)
);

-- Une seule clé par adresse e-mail
create unique index if not exists cles_email_unique on public.cles (lower(email));

-- Sécurité : le site peut seulement AJOUTER une clé, jamais lire la liste.
alter table public.cles enable row level security;

drop policy if exists "le site cree des cles" on public.cles;
create policy "le site cree des cles"
  on public.cles for insert
  to anon
  with check (niveau = 'Voisin');

-- Pour le jury : nombre de clés par affiche scannée
create or replace view public.cles_par_source
  with (security_invoker = true) as
  select source, count(*) as cles
  from public.cles
  group by source
  order by cles desc;
