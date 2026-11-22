export default defineNuxtConfig({
  compatibilityDate: '2024-11-01',
  devtools: { enabled: true },
  
  modules: ['@nuxtjs/tailwindcss', '@nuxtjs/supabase', '@nuxtjs/color-mode', '@nuxt/icon'],

  css: ['~/assets/css/main.css'],

  supabase: {
    url: process.env.NUXT_PUBLIC_SUPABASE_URL ?? process.env.SUPABASE_URL,
    key: process.env.NUXT_PUBLIC_SUPABASE_KEY ?? process.env.SUPABASE_KEY,
    redirect: false,
    useSsrCookies: false
  },

  colorMode: {
    classSuffix: '',
    preference: 'dark',
    fallback: 'dark'
  },

  app: {
    head: {
      title: 'Zboard',
      htmlAttrs: {
        class: 'dark'
      },
      link: [
        { rel: 'icon', type: 'image/jpeg', href: '/zaulog.jpg' },
        { rel: 'preconnect', href: 'https://fonts.googleapis.com' },
        { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: '' },
        { rel: 'stylesheet', href: 'https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&display=swap' }
      ]
    }
  },

  ssr: false,
  
  nitro: {
    preset: 'static'
  }
})