export default defineNuxtConfig({
  compatibilityDate: '2024-11-01',
  devtools: { enabled: true },
  
  modules: [
    '@nuxtjs/tailwindcss',
    '@nuxtjs/supabase',
    '@nuxtjs/color-mode'
  ],

  css: ['~/assets/css/main.css'],

  supabase: {
    redirect: false
  },

  colorMode: {
    classSuffix: '',
    preference: 'dark',
    fallback: 'dark'
  },

  app: {
    head: {
      title: 'Flowboard',
      htmlAttrs: {
        class: 'dark'
      },
      link: [
        { rel: 'preconnect', href: 'https://fonts.googleapis.com' },
        { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: '' },
        { rel: 'stylesheet', href: 'https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&display=swap' }
      ]
    }
  },

  ssr: false, // Importante para SPA en Netlify
  
  nitro: {
    preset: 'netlify'
  }
})
