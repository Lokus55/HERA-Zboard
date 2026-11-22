<script setup lang="ts">
import type { MessageKey } from '~/utils/interfaceMessages'

const props = defineProps<{ workspaceId: string }>()
const emit = defineEmits<{ memberAdded: [] }>()
const { t } = useInterfaceLanguage()
const supabase = useSupabaseClient()
const router = useRouter()

const email = ref('')
const emailInput = ref<HTMLInputElement | null>(null)
const busy = ref(false)
const error = ref<MessageKey | null>(null)
const feedback = ref<MessageKey | null>(null)
const invitation = ref<{ link: string, email: string } | null>(null)

const emailDraft = computed(() => {
  if (!invitation.value) return ''
  const address = encodeURIComponent(invitation.value.email).replace('%40', '@')
  const subject = encodeURIComponent(t('invitationSubject'))
  const body = encodeURIComponent(t('invitationEmailBody', { link: invitation.value.link }))
  return `mailto:${address}?subject=${subject}&body=${body}`
})

async function submit(mode: 'invite' | 'existing') {
  if (busy.value || !emailInput.value?.reportValidity()) return
  const memberEmail = email.value.trim()
  busy.value = true
  feedback.value = null
  error.value = null
  invitation.value = null
  try {
    if (mode === 'existing') {
      const { error: failure } = await supabase.rpc('add_workspace_member', {
        workspace: props.workspaceId,
        member_email: memberEmail,
      })
      if (failure) {
        error.value = failure.code === '42501' ? 'ownerOnly'
          : failure.code === 'P0001' ? 'memberNotFound' : 'memberAddError'
        return
      }
      emit('memberAdded')
      feedback.value = 'memberAdded'
      email.value = ''
      return
    }

    const { data: token, error: failure } = await supabase.rpc('create_workspace_invite', {
      workspace: props.workspaceId,
      invite_email: memberEmail,
    })
    if (failure || typeof token !== 'string' || !isInvitationToken(token)) {
      error.value = failure?.code === '23505' ? 'alreadyWorkspaceMember' : 'invitationCreateError'
      return
    }
    const url = new URL(router.resolve('/invite').href, window.location.origin)
    url.hash = token
    invitation.value = { link: url.toString(), email: memberEmail }
  } catch {
    error.value = mode === 'invite' ? 'invitationCreateError' : 'memberAddError'
  } finally {
    busy.value = false
  }
}

async function copyInvitation() {
  if (!invitation.value) return
  try {
    await navigator.clipboard.writeText(invitation.value.link)
    feedback.value = 'copied'
  } catch {
    error.value = 'invitationCopyError'
  }
}
</script>

<template>
  <form class="space-y-3" @submit.prevent="submit('invite')">
    <label class="block text-sm font-medium text-neutral-400">
      {{ t('email') }}
      <input
        ref="emailInput"
        v-model="email"
        type="email"
        autocomplete="email"
        maxlength="254"
        required
        :disabled="busy"
        :placeholder="t('emailPlaceholder')"
        class="input mt-1"
        @input="invitation = null; error = null; feedback = null"
      >
    </label>
    <div class="flex flex-wrap items-center gap-2">
      <button type="submit" class="btn-primary" :disabled="busy">{{ t('createInvitation') }}</button>
      <button type="button" class="btn-secondary" :disabled="busy" @click="submit('existing')">
        {{ t('addExistingAccount') }}
      </button>
    </div>
    <p v-if="error" role="alert" class="text-sm text-red-400">{{ t(error) }}</p>
    <p v-if="feedback" role="status" class="text-sm text-green-400">{{ t(feedback) }}</p>
    <div v-if="invitation" class="space-y-2 rounded-lg border border-neutral-700 p-3">
      <p class="text-sm text-neutral-300">{{ t('invitationLinkHint') }}</p>
      <input
        :value="invitation.link"
        :aria-label="t('invitationLink')"
        readonly
        class="input text-sm"
        @focus="($event.target as HTMLInputElement).select()"
      >
      <div class="flex flex-wrap gap-2">
        <a :href="emailDraft" class="btn-primary">{{ t('openEmailDraft') }}</a>
        <button type="button" class="btn-secondary" @click="copyInvitation">{{ t('copy') }}</button>
      </div>
    </div>
  </form>
</template>
