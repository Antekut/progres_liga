// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  app: {
    head: {
      title: 'Progres Liga',
    },
  },
  compatibilityDate: '2025-05-15',
  modules: ['@nuxt/eslint'],
  eslint: {
    config: {
      typescript: false,
    },
  },
  devtools: { enabled: true },
  runtimeConfig: {
    public: {
      apiUrl: process.env.NUXT_PUBLIC_API_URL || 'http://localhost:8000',
      supabaseUrl: process.env.NUXT_PUBLIC_SUPABASE_URL || '',
      supabasePublishableKey: process.env.NUXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY || '',
    },
  },
  nitro: {
    preset: 'vercel',
  },
})
