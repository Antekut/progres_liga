# ProgresLiga

Aplikacja siłowniana pokazująca **ranking Twojego progresu na tle innych** — punkty za treningi, tygodniowy wzrost i pozycja w lidze.

Monorepo (Nuxt + FastAPI + Supabase), oparte na szablonie `template`.

## Struktura

```
apps/web/           frontend Nuxt — tablica wyników
services/api/       FastAPI — endpointy rankingu
supabase/           migracje (tabela athletes + przykładowe dane)
```

## Lokalny start

```bash
cd ~/antek/progres_liga
pnpm install
pnpm supabase:start
pnpm env:local
pnpm dev
```

Otwórz http://localhost:3000.

Lokalny Supabase używa portów **55451+** (żeby nie kolidować z innymi projektami).

Studio: http://127.0.0.1:55443

## Co jest w środku

- Tabela `athletes` z punktami, tygodniowym wzrostem (`weekly_gain_pct`) i flagą `is_you`
- Strona główna z rankingiem i wyróżnioną Twoją pozycją
- API: `/api/tagline`, `/api/leaderboard`
