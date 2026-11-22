<template>
  <div class="relative">
    <button 
      @click="isOpen = !isOpen"
      :aria-label="t('notifications')"
      class="relative p-2 text-neutral-400 hover:text-white transition-colors"
    >
      <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
      </svg>
      <span 
        v-if="unreadCount > 0" 
        class="absolute top-1 right-1 w-4 h-4 bg-red-500 rounded-full text-[10px] flex items-center justify-center text-white font-bold"
      >
        {{ unreadCount > 9 ? '9+' : unreadCount }}
      </span>
    </button>

    <!-- Dropdown -->
    <div 
      v-if="isOpen" 
      class="absolute right-0 mt-2 w-80 bg-neutral-900 border border-neutral-800 rounded-xl shadow-xl z-50 overflow-hidden"
    >
      <div class="p-3 border-b border-neutral-800 flex items-center justify-between">
        <h3 class="font-semibold">{{ t('notifications') }}</h3>
        <button 
          v-if="unreadCount > 0"
          @click="markAllRead" 
          class="text-xs text-cyan-400 hover:text-cyan-300"
        >
          {{ t('markAllRead') }}
        </button>
      </div>

      <div class="max-h-80 overflow-y-auto">
        <div v-if="notifications.length === 0" class="p-4 text-center text-neutral-500 text-sm">
          {{ t('noNotifications') }}
        </div>
        
        <div 
          v-for="notif in notifications" 
          :key="notif.id"
          @click="handleClick(notif)"
          class="p-3 border-b border-neutral-800 hover:bg-neutral-800/50 cursor-pointer transition-colors"
          :class="{ 'bg-neutral-800/30': !notif.is_read }"
        >
          <div class="flex items-start gap-3">
            <div 
              class="w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0"
              :class="{
                'bg-cyan-500/20 text-cyan-400': notif.type === 'task_assigned',
                'bg-purple-500/20 text-purple-400': notif.type === 'mentioned',
                'bg-amber-500/20 text-amber-400': notif.type === 'task_updated'
              }"
            >
              <svg v-if="notif.type === 'task_assigned'" class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
              </svg>
              <svg v-else-if="notif.type === 'mentioned'" class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.207" />
              </svg>
              <svg v-else class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
              </svg>
            </div>
            <div class="flex-1 min-w-0">
              <p class="text-sm font-medium" :class="{ 'text-white': !notif.is_read, 'text-neutral-300': notif.is_read }">
                {{ notif.type === 'task_assigned' ? t('taskAssignedTitle') : notif.title }}
              </p>
              <p class="text-xs text-neutral-500 truncate">{{ notificationMessage(notif) }}</p>
              <p class="text-xs text-neutral-600 mt-1">{{ formatTime(notif.created_at) }}</p>
            </div>
            <div v-if="!notif.is_read" class="w-2 h-2 rounded-full bg-cyan-400 flex-shrink-0 mt-2" />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const { t, relativeTime } = useInterfaceLanguage()
const supabase = useSupabaseClient()
const user = useSupabaseUser()
const router = useRouter()

const isOpen = ref(false)
const notifications = ref<any[]>([])

const unreadCount = computed(() => notifications.value.filter(n => !n.is_read).length)

const getUserId = (u: any): string | null => {
  if (!u) return null
  return u.id || u.sub || null
}

const formatTime = (date: string) => {
  const d = new Date(date)
  const now = new Date()
  const diff = now.getTime() - d.getTime()
  const minutes = Math.floor(diff / 60000)
  const hours = Math.floor(diff / 3600000)
  const days = Math.floor(diff / 86400000)
  
  if (minutes < 60) return relativeTime(-Math.max(0, minutes), "minute")
  if (hours < 24) return relativeTime(-hours, "hour")
  return relativeTime(-days, "day")
}

const notificationMessage = (notification: { type: string, message: string }) => {
  if (notification.type !== "task_assigned") return notification.message
  // Older and current database installs store the assignment message as Spanish text.
  const assignment = /^Te han asignado "([\s\S]*)"$/.exec(notification.message)
  return assignment ? t("taskAssignedMessage", { title: assignment[1] ?? "" }) : notification.message
}

const loadNotifications = async () => {
  const userId = getUserId(user.value)
  if (!userId) return

  const { data } = await supabase
    .from('notifications')
    .select('*')
    .eq('user_id', userId)
    .order('created_at', { ascending: false })
    .limit(20)

  if (data) {
    notifications.value = data
  }
}

const markAllRead = async () => {
  const userId = getUserId(user.value)
  if (!userId) return

  await supabase
    .from('notifications')
    .update({ is_read: true })
    .eq('user_id', userId)
    .eq('is_read', false)

  notifications.value.forEach(n => n.is_read = true)
}

const handleClick = async (notif: any) => {
  if (!notif.is_read) {
    await supabase
      .from('notifications')
      .update({ is_read: true })
      .eq('id', notif.id)
    
    notif.is_read = true
  }

  isOpen.value = false
  
  if (notif.link) {
    router.push(notif.link)
  }
}

// Close on click outside
const handleClickOutside = (e: MouseEvent) => {
  const target = e.target as HTMLElement
  if (!target.closest('.relative')) {
    isOpen.value = false
  }
}

onMounted(() => {
  loadNotifications()
  document.addEventListener('click', handleClickOutside)
  
  // Poll for new notifications every 30 seconds
  const interval = setInterval(loadNotifications, 30000)
  onUnmounted(() => {
    clearInterval(interval)
    document.removeEventListener('click', handleClickOutside)
  })
})

watch(() => user.value, () => {
  loadNotifications()
}, { immediate: true })
</script>
