<script setup lang="ts">
import { createClient } from '@supabase/supabase-js'

type Athlete = {
  id: number
  name: string
  score: number
  weekly_gain_pct: number
  is_you: boolean
}

const config = useRuntimeConfig()

const tagline = ref<string | null>(null)
const apiError = ref<string | null>(null)
const athletes = ref<Athlete[]>([])
const dbError = ref<string | null>(null)

const yourRank = computed(() => {
  const index = athletes.value.findIndex((a) => a.is_you)
  return index >= 0 ? index + 1 : null
})

onMounted(async () => {
  try {
    const res = await fetch(`${config.public.apiUrl}/api/tagline`)
    if (!res.ok) throw new Error(`${res.status} ${res.statusText}`)
    const data = (await res.json()) as { message: string }
    tagline.value = data.message
  } catch (e) {
    apiError.value = e instanceof Error ? e.message : 'API request failed'
  }

  const url = config.public.supabaseUrl
  const key = config.public.supabasePublishableKey
  if (!url || !key) {
    dbError.value = 'Set NUXT_PUBLIC_SUPABASE_URL and NUXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY'
    return
  }

  try {
    const supabase = createClient(url, key)
    const { data, error } = await supabase
      .from('athletes')
      .select('id, name, score, weekly_gain_pct, is_you')
      .order('score', { ascending: false })
    if (error) throw error
    athletes.value = data ?? []
  } catch (e) {
    dbError.value = e instanceof Error ? e.message : 'Supabase request failed'
  }
})
</script>

<template>
  <main class="page">
    <header class="hero">
      <h1 class="site-title">Progres <span>Liga</span></h1>
      <p class="tag">Ranking progresu</p>
      <p v-if="tagline" class="subtitle">{{ tagline }}</p>
      <p v-else-if="apiError" class="err">{{ apiError }}</p>
      <p v-else class="muted">Ładowanie…</p>
    </header>

    <section v-if="yourRank" class="your-rank card">
      <span class="label">Twoja pozycja</span>
      <strong class="rank">#{{ yourRank }}</strong>
      <span class="of">z {{ athletes.length }} zawodników</span>
    </section>

    <section class="card">
      <h2>Tablica wyników</h2>
      <p v-if="dbError" class="err">{{ dbError }}</p>
      <p v-else-if="!athletes.length" class="muted">Ładowanie rankingu…</p>
      <ol v-else class="leaderboard">
        <li
          v-for="(athlete, index) in athletes"
          :key="athlete.id"
          :class="{ you: athlete.is_you }"
        >
          <span class="position">{{ index + 1 }}</span>
          <span class="name">{{ athlete.name }}</span>
          <span class="score">{{ athlete.score }} pkt</span>
          <span class="gain" :class="{ up: athlete.weekly_gain_pct > 0 }">
            {{ athlete.weekly_gain_pct > 0 ? '+' : '' }}{{ athlete.weekly_gain_pct }}%
          </span>
        </li>
      </ol>
    </section>
  </main>
</template>

<style scoped>
.page {
  font-family: system-ui, sans-serif;
  max-width: 36rem;
  margin: 0 auto;
  padding: 2rem 1rem;
  background: #0f1419;
  min-height: 100vh;
  color: #e8edf2;
}

.hero {
  margin-bottom: 2rem;
  text-align: center;
}

.site-title {
  margin: 0;
  font-size: clamp(2.5rem, 10vw, 3.5rem);
  font-weight: 800;
  letter-spacing: -0.03em;
  line-height: 1.05;
  color: #f4f8fb;
}

.site-title span {
  background: linear-gradient(135deg, #6ee7a8 0%, #34d399 50%, #a7f3d0 100%);
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
}

.tag {
  margin: 0.75rem 0 0;
  font-size: 0.8rem;
  font-weight: 600;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: #6b7d8c;
}

.subtitle {
  color: #9aa8b5;
  margin: 0.75rem 0 0;
  font-size: 1.05rem;
  line-height: 1.5;
}

.your-rank {
  display: flex;
  align-items: baseline;
  gap: 0.5rem;
  margin-bottom: 1rem;
  background: linear-gradient(135deg, #1a2e24, #15202b);
  border-color: #2d5a40;
}

.your-rank .label {
  color: #6ee7a8;
  font-size: 0.85rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.your-rank .rank {
  font-size: 1.75rem;
  color: #fff;
}

.your-rank .of {
  color: #9aa8b5;
  font-size: 0.9rem;
}

.card {
  border: 1px solid #2a3440;
  border-radius: 12px;
  padding: 1rem 1.25rem;
  margin-bottom: 1rem;
  background: #15202b;
}

.card h2 {
  margin: 0 0 1rem;
  font-size: 0.85rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: #9aa8b5;
}

.leaderboard {
  list-style: none;
  margin: 0;
  padding: 0;
}

.leaderboard li {
  display: grid;
  grid-template-columns: 2rem 1fr auto auto;
  gap: 0.75rem;
  align-items: center;
  padding: 0.65rem 0;
  border-bottom: 1px solid #2a3440;
}

.leaderboard li:last-child {
  border-bottom: none;
}

.leaderboard li.you {
  background: #1a2e24;
  margin: 0 -1.25rem;
  padding: 0.65rem 1.25rem;
  border-radius: 8px;
  border-bottom: none;
}

.position {
  font-weight: 700;
  color: #6ee7a8;
}

.name {
  font-weight: 500;
}

.score {
  color: #e8edf2;
  font-variant-numeric: tabular-nums;
}

.gain {
  color: #9aa8b5;
  font-size: 0.85rem;
  font-variant-numeric: tabular-nums;
}

.gain.up {
  color: #6ee7a8;
}

.err {
  color: #f87171;
}

.muted {
  color: #9aa8b5;
}
</style>
