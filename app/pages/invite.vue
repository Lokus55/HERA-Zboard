<script setup lang="ts">
import type { MessageKey } from '~/utils/interfaceMessages'

const { t } = useInterfaceLanguage()
const route = useRoute()
const router = useRouter()
const supabase = useSupabaseClient()
const session = useSupabaseSession()

const token = ref<string | null>(null)
const ready = ref(false)
const busy = ref(false)
const error = ref<MessageKey | null>(null)

onMounted(async () => {
  const fragment = route.hash.slice(1)
  if (fragment) {
    if (isInvitationToken(fragment)) {
      token.value = fragment
      setPendingInvitation(fragment)
      await router.replace({ path: route.path, query: route.query })
    }
  } else {
    token.value = getPendingInvitation()
  }
  await supabase.auth.getSession()
  ready.value = true
})

async function acceptInvitation() {
  if (!token.value || busy.value) return
  busy.value = true
  error.value = null
  try {
    const { data: workspace, error: failure } = await supabase.rpc('accept_workspace_invite', {
      invite_token: token.value,
    })
    if (failure || typeof workspace !== 'string') {
      error.value = failure?.code === 'P0002' ? 'invitationInvalid'
        : failure?.code === '42501' ? 'invitationWrongEmail' : 'invitationAcceptError'
      if (failure?.code === 'P0002') {
        setPendingInvitation(null)
        token.value = null
      }
      return
    }
    setPendingInvitation(null)
    try {
      localStorage.setItem('lastWorkspaceId', workspace)
    } catch {
      // The membership is saved even when browser storage is unavailable.
    }
    await navigateTo('/dashboard')
  } catch {
    error.value = 'invitationAcceptError'
  } finally {
    busy.value = false
  }
}

async function switchAccount() {
  busy.value = true
  try {
    const { error: failure } = await supabase.auth.signOut({ scope: 'local' })
    if (failure) {
      error.value = 'unexpectedError'
      return
    }
    await navigateTo('/auth/login')
  } catch {
    error.value = 'unexpectedError'
  } finally {
    busy.value = false
  }
}

function leaveInvitation() {
  setPendingInvitation(null)
  return navigateTo(session.value ? '/dashboard' : '/')
}
</script>

<template>
  <main class="flex min-h-screen items-center justify-center p-4">
    <div class="card w-full max-w-md space-y-4 p-6">
      <div class="flex flex-wrap items-center justify-between gap-3">
        <h1 class="text-xl font-bold">{{ t('workspaceInvitation') }}</h1>
        <AppLanguagePicker />
      </div>
      <p v-if="!ready" role="status">{{ t('loading') }}</p>
      <p v-else-if="!token" role="alert" class="text-sm text-red-400">{{ t('invitationInvalid') }}</p>
      <template v-else>
        <p class="text-sm text-neutral-300">{{ t('invitationSignInHint') }}</p>
        <p v-if="error" role="alert" class="text-sm text-red-400">{{ t(error) }}</p>
        <div class="flex flex-wrap gap-2">
          <template v-if="session">
            <button type="button" :disabled="busy" class="btn-primary" @click="acceptInvitation">
              {{ t('acceptInvitation') }}
            </button>
            <button type="button" :disabled="busy" class="btn-secondary" @click="switchAccount">
              {{ t('switchAccount') }}
            </button>
          </template>
          <template v-else>
            <NuxtLink to="/auth/login" class="btn-primary">{{ t('signIn') }}</NuxtLink>
            <NuxtLink to="/auth/register" class="btn-secondary">{{ t('createAccount') }}</NuxtLink>
          </template>
        </div>
      </template>
      <button type="button" :disabled="busy" class="btn-ghost" @click="leaveInvitation">{{ t('cancel') }}</button>
    </div>
  </main>
</template>
