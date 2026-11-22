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
        <h1 class="text-2xl font-bold mb-2 text-center">Crea tu cuenta</h1>
        <p class="text-neutral-400 text-center mb-8">Empieza a organizar tus proyectos</p>

        <form @submit.prevent="handleRegister" class="space-y-5">
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5">Nombre</label>
            <input
              v-model="fullName"
              type="text"
              placeholder="Tu nombre"
              required
              class="input"
            >
          </div>

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
              placeholder="Mínimo 8 caracteres"
              required
              class="input"
            >
          </div>

          <div v-if="error" class="p-3 rounded-lg bg-red-500/10 border border-red-500/20 text-red-400 text-sm">
            {{ error }}
          </div>

          <div v-if="success" class="p-3 rounded-lg bg-green-500/10 border border-green-500/20 text-green-400 text-sm">
            {{ success }}
          </div>

          <button type="submit" class="btn-primary w-full" :disabled="loading">
            {{ loading ? 'Cargando...' : 'Crear cuenta' }}
          </button>
        </form>

        <p class="mt-6 text-center text-sm text-neutral-400">
          ¿Ya tienes cuenta?
          <NuxtLink to="/auth/login" class="text-cyan-400 hover:text-cyan-300">
            Inicia sesión
          </NuxtLink>
        </p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const supabase = useSupabaseClient()

const fullName = ref('')
const email = ref('')
const password = ref('')
const loading = ref(false)
const error = ref('')
const success = ref('')

const handleRegister = async () => {
  error.value = ''
  success.value = ''
  loading.value = true

  try {
    const { data, error: authError } = await supabase.auth.signUp({
      email: email.value,
      password: password.value,
      options: {
        data: { full_name: fullName.value },
        emailRedirectTo: window.location.origin + '/auth/login'
      }
    })

    if (authError) {
      error.value = authError.message
      return
    }

    if (data.session) {
      await navigateTo('/dashboard')
      return
    }

    success.value = '¡Cuenta creada! Revisa tu email para confirmar.'
  } catch (e) {
    error.value = 'Ha ocurrido un error'
  } finally {
    loading.value = false
  }
}
</script>
