<template>
  <div class="min-h-screen flex items-center justify-center p-4">
    <div class="w-full max-w-md">
      <div class="flex items-center justify-between gap-3 mb-8">
        <NuxtLink to="/" class="inline-flex items-center gap-3">
          <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-cyan-400 to-cyan-600 flex items-center justify-center">
            <span class="text-neutral-950 font-bold">Z</span>
          </div>
          <span class="font-bold text-2xl">Zboard</span>
        </NuxtLink>
        <AppLanguagePicker />
      </div>

      <div class="card p-8">
        <h1 class="text-2xl font-bold mb-2 text-center">{{ t('registerHeading') }}</h1>
        <p class="text-neutral-400 text-center mb-8">{{ t('registerSubtitle') }}</p>

        <form @submit.prevent="handleRegister" class="space-y-5">
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5">{{ t('name') }}</label>
            <input
              v-model="fullName"
              type="text"
              :placeholder="t('yourName')"
              required
              class="input"
            >
          </div>

          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5">{{ t('email') }}</label>
            <input
              v-model="email"
              type="email"
              :placeholder="t('emailPlaceholder')"
              required
              class="input"
            >
          </div>

          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5">{{ t('password') }}</label>
            <input
              v-model="password"
              type="password"
              :placeholder="t('passwordLength')"
              required
              class="input"
            >
          </div>

          <div v-if="error" class="p-3 rounded-lg bg-red-500/10 border border-red-500/20 text-red-400 text-sm">
            {{ t(error) }}
          </div>

          <div v-if="success" class="p-3 rounded-lg bg-green-500/10 border border-green-500/20 text-green-400 text-sm">
            {{ t('accountCreated') }}
          </div>

          <button type="submit" class="btn-primary w-full" :disabled="loading">
            {{ loading ? t('loading') : t('createAccount') }}
          </button>
        </form>

        <p class="mt-6 text-center text-sm text-neutral-400">
          {{ t('haveAccount') }}
          <NuxtLink to="/auth/login" class="text-cyan-400 hover:text-cyan-300">
            {{ t('signIn') }}
          </NuxtLink>
        </p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { MessageKey } from '~/utils/interfaceMessages'

const { t } = useInterfaceLanguage()
const supabase = useSupabaseClient()

const fullName = ref('')
const email = ref('')
const password = ref('')
const loading = ref(false)
const error = ref<MessageKey | null>(null)
const success = ref(false)

const handleRegister = async () => {
  error.value = null
  success.value = false
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
      console.error('Could not register:', authError)
      error.value = authError.code === 'weak_password' ? 'weakPassword' : 'registerError'
      return
    }

    if (data.session) {
      await navigateTo(getPendingInvitation() ? '/invite' : '/dashboard')
      return
    }

    success.value = true
  } catch {
    error.value = 'unexpectedError'
  } finally {
    loading.value = false
  }
}
</script>
