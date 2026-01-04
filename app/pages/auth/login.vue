<template>
  <div class="min-h-screen flex items-center justify-center p-4">
    <div class="w-full max-w-md">
      <div class="text-center mb-8">
        <NuxtLink to="/" class="inline-flex items-center gap-3">
          <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-cyan-400 to-cyan-600 flex items-center justify-center">
            <span class="text-neutral-950 font-bold">Z</span>
          </div>
          <span class="font-bold text-2xl">Zboard</span>
        </NuxtLink>
      </div>

      <div class="card p-8">
        <h1 class="text-2xl font-bold mb-2 text-center">Bienvenido de nuevo</h1>
        <p class="text-neutral-400 text-center mb-8">Inicia sesión para continuar</p>

        <form @submit.prevent="handleLogin" class="space-y-5">
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5">Email</label>
            <input
              v-model="email"
              type="email"
              placeholder="tu@email.com"
              required
              class="input"
            >
          </div>

          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5">Contraseña</label>
            <input
              v-model="password"
              type="password"
              placeholder="••••••••"
              required
              class="input"
            >
          </div>

          <div v-if="error" class="p-3 rounded-lg bg-red-500/10 border border-red-500/20 text-red-400 text-sm">
            {{ error }}
          </div>

          <button type="submit" class="btn-primary w-full" :disabled="loading">
            {{ loading ? 'Cargando...' : 'Iniciar sesión' }}
          </button>
        </form>

        <p class="mt-6 text-center text-sm text-neutral-400">
          ¿No tienes cuenta?
          <NuxtLink to="/auth/register" class="text-cyan-400 hover:text-cyan-300">
            Regístrate gratis
          </NuxtLink>
        </p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const supabase = useSupabaseClient()

const email = ref('')
const password = ref('')
const loading = ref(false)
const error = ref('')

const handleLogin = async () => {
  error.value = ''
  loading.value = true

  try {
    const { error: authError } = await supabase.auth.signInWithPassword({
      email: email.value,
      password: password.value
    })

    if (authError) {
      error.value = 'Email o contraseña incorrectos'
      return
    }

    navigateTo('/dashboard')
  } catch (e) {
    error.value = 'Ha ocurrido un error'
  } finally {
    loading.value = false
  }
}
</script>
