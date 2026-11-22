<template>
  <div class="min-h-screen flex items-center justify-center p-4">
    <div class="w-full max-w-md">
      <div class="flex items-center justify-between gap-3 mb-8">
        <NuxtLink to="/" class="inline-flex items-center gap-3">
          <div
            class="w-10 h-10 rounded-xl bg-gradient-to-br from-cyan-400 to-cyan-600 flex items-center justify-center"
          >
            <span class="text-neutral-950 font-bold">Z</span>
          </div>
          <span class="font-bold text-2xl">Zboard</span>
        </NuxtLink>
        <AppLanguagePicker />
      </div>

      <div class="card p-8">
        <h1 class="text-2xl font-bold mb-2 text-center">{{ t('welcomeBack') }}</h1>
        <p class="text-neutral-400 text-center mb-8">
          {{ t('signInToContinue') }}
        </p>

        <form @submit.prevent="handleLogin" class="space-y-5">
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5"
              >{{ t('email') }}</label
            >
            <input
              v-model="email"
              type="email"
              :placeholder="t('emailPlaceholder')"
              required
              class="input"
            />
          </div>

          <div class="block">
            <label class="block text-sm font-medium text-neutral-400 mb-1.5">
              {{ t('password') }}
            </label>

            <div class="relative">
              <input
                v-model="password"
                :type="passwordVisible ? 'text' : 'password'"
                placeholder="••••••••"
                required
                class="input pr-10"
              />
              <button
                type="button"
                @click="passwordVisible = !passwordVisible"
                :aria-label="
                  passwordVisible ? t('hidePassword') : t('showPassword')
                "
                class="absolute right-3 top-1/2 -translate-y-1/2 text-neutral-500 hover:text-neutral-700 focus:outline-none"
              >
                <Icon
                  :name="passwordVisible ? 'lucide:eye-off' : 'lucide:eye'"
                  class="w-5 h-5" :class="passwordVisible ? ' text-cyan-300' : 'text-neutral-500'"
                />
              </button>
            </div>
          </div>

          <div
            v-if="error"
            class="p-3 rounded-lg bg-red-500/10 border border-red-500/20 text-red-400 text-sm"
          >
            {{ t(error) }}
          </div>

          <button type="submit" class="btn-primary w-full" :disabled="loading">
            {{ loading ? t('loading') : t('signIn') }}
          </button>
        </form>

        <p class="mt-6 text-center text-sm text-neutral-400">
          {{ t('noAccount') }}
          <NuxtLink
            to="/auth/register"
            class="text-cyan-400 hover:text-cyan-300"
          >
            {{ t('signUp') }}
          </NuxtLink>
        </p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { MessageKey } from '~/utils/interfaceMessages'

const { t } = useInterfaceLanguage()
const supabase = useSupabaseClient();

const email = ref("");
const password = ref("");
const loading = ref(false);
const error = ref<MessageKey | null>(null);
const passwordVisible = ref(false);

onMounted(async () => {
  const { data: { session } } = await supabase.auth.getSession();
  if (session) await navigateTo(getPendingInvitation() ? "/invite" : "/dashboard");
});

const handleLogin = async () => {
  error.value = null;
  loading.value = true;

  try {
    const { error: authError } = await supabase.auth.signInWithPassword({
      email: email.value,
      password: password.value,
    });

    if (authError) {
      error.value = authError.code === 'invalid_credentials' ? 'invalidCredentials' : 'unexpectedError';
      return;
    }

    await navigateTo(getPendingInvitation() ? "/invite" : "/dashboard");
  } catch {
    error.value = 'unexpectedError';
  } finally {
    loading.value = false;
  }
};
</script>
