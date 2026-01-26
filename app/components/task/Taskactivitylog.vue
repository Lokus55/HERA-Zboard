<template>
  <div class="space-y-3">
    <div class="flex items-center justify-between">
      <h4 class="text-sm font-medium text-neutral-300">Historial de actividad</h4>
      <button 
        v-if="activities.length > 5 && !showAll" 
        @click="showAll = true"
        class="text-xs text-cyan-400 hover:text-cyan-300"
      >
        Ver todo ({{ activities.length }})
      </button>
    </div>

    <div v-if="loading" class="text-sm text-neutral-500 py-4 text-center">
      Cargando historial...
    </div>

    <div v-else-if="activities.length === 0" class="text-sm text-neutral-500 py-4 text-center">
      No hay actividad registrada
    </div>

    <div v-else class="space-y-2 max-h-64 overflow-y-auto pr-1">
      <div 
        v-for="activity in displayedActivities" 
        :key="activity.id"
        class="flex gap-3 py-2 border-b border-neutral-800 last:border-0"
      >
        <!-- Icono según el tipo de acción -->
        <div class="flex-shrink-0 mt-0.5">
          <div 
            class="w-7 h-7 rounded-full flex items-center justify-center"
            :class="getActionIconClass(activity.action)"
          >
            <!-- Created -->
            <svg v-if="activity.action === 'created'" class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
            </svg>
            <!-- Status Changed -->
            <svg v-else-if="activity.action === 'status_changed'" class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6" />
            </svg>
            <!-- Assigned -->
            <svg v-else-if="activity.action === 'assigned'" class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" />
            </svg>
            <!-- Unassigned -->
            <svg v-else-if="activity.action === 'unassigned'" class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7a4 4 0 11-8 0 4 4 0 018 0zM9 14a6 6 0 00-6 6v1h12v-1a6 6 0 00-6-6zM21 12h-6" />
            </svg>
            <!-- Label Added/Removed -->
            <svg v-else-if="activity.action === 'label_added' || activity.action === 'label_removed'" class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z" />
            </svg>
            <!-- Updated -->
            <svg v-else-if="activity.action === 'updated'" class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
            </svg>
            <!-- Deleted -->
            <svg v-else-if="activity.action === 'deleted'" class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
            </svg>
            <!-- Default -->
            <svg v-else class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
        </div>

        <!-- Contenido -->
        <div class="flex-1 min-w-0">
          <p class="text-sm text-neutral-300">
            <span class="font-medium text-white">{{ activity.user_name || 'Sistema' }}</span>
            {{ getActionText(activity) }}
          </p>
          <p class="text-xs text-neutral-500 mt-0.5">
            {{ formatDate(activity.created_at) }}
          </p>
        </div>
      </div>
    </div>

    <button 
      v-if="showAll && activities.length > 5" 
      @click="showAll = false"
      class="text-xs text-neutral-400 hover:text-neutral-300 w-full text-center py-1"
    >
      Mostrar menos
    </button>
  </div>
</template>

<script setup lang="ts">
const props = defineProps<{
  taskId: string
}>()

const supabase = useSupabaseClient()

const activities = ref<any[]>([])
const loading = ref(true)
const showAll = ref(false)

const displayedActivities = computed(() => {
  return showAll.value ? activities.value : activities.value.slice(0, 5)
})

const loadActivities = async () => {
  if (!props.taskId) return
  
  loading.value = true
  
  const { data } = await supabase
    .from('task_activities')
    .select(`
      *,
      profiles:user_id (full_name, email)
    `)
    .eq('task_id', props.taskId)
    .order('created_at', { ascending: false })
    .limit(50)
  
  if (data) {
    activities.value = data.map(a => ({
      ...a,
      user_name: a.profiles?.full_name || a.profiles?.email || null
    }))
  }
  
  loading.value = false
}

const getActionIconClass = (action: string) => {
  const classes: Record<string, string> = {
    'created': 'bg-green-500/20 text-green-400',
    'status_changed': 'bg-blue-500/20 text-blue-400',
    'assigned': 'bg-cyan-500/20 text-cyan-400',
    'unassigned': 'bg-orange-500/20 text-orange-400',
    'label_added': 'bg-purple-500/20 text-purple-400',
    'label_removed': 'bg-purple-500/20 text-purple-400',
    'updated': 'bg-yellow-500/20 text-yellow-400',
    'deleted': 'bg-red-500/20 text-red-400'
  }
  return classes[action] || 'bg-neutral-700 text-neutral-400'
}

const getActionText = (activity: any) => {
  const action = activity.action
  const field = activity.field_name
  const oldVal = activity.old_value
  const newVal = activity.new_value

  switch (action) {
    case 'created':
      return ' creó esta tarea'
    
    case 'status_changed':
      return ` movió de "${oldVal}" a "${newVal}"`
    
    case 'assigned':
      return ` asignó a ${newVal}`
    
    case 'unassigned':
      return ` removió a ${oldVal}`
    
    case 'label_added':
      return ` agregó la etiqueta "${newVal}"`
    
    case 'label_removed':
      return ` quitó la etiqueta "${oldVal}"`
    
    case 'updated':
      if (field === 'title') {
        return ` cambió el título de "${oldVal}" a "${newVal}"`
      }
      if (field === 'description') {
        return ' actualizó la descripción'
      }
      if (field === 'priority') {
        return ` cambió la prioridad de "${formatPriority(oldVal)}" a "${formatPriority(newVal)}"`
      }
      if (field === 'due_date') {
        if (!oldVal && newVal) return ` estableció fecha límite: ${formatShortDate(newVal)}`
        if (oldVal && !newVal) return ' eliminó la fecha límite'
        return ` cambió fecha límite a ${formatShortDate(newVal)}`
      }
      return ` actualizó ${field}`
    
    case 'deleted':
      return ' eliminó esta tarea'
    
    default:
      return ` ${action}`
  }
}

const formatPriority = (priority: string) => {
  const map: Record<string, string> = {
    'low': 'Baja',
    'medium': 'Media',
    'high': 'Alta',
    'urgent': 'Urgente'
  }
  return map[priority] || priority
}

const formatDate = (date: string) => {
  const d = new Date(date)
  const now = new Date()
  const diff = now.getTime() - d.getTime()
  
  const minutes = Math.floor(diff / 60000)
  const hours = Math.floor(diff / 3600000)
  const days = Math.floor(diff / 86400000)
  
  if (minutes < 1) return 'Ahora mismo'
  if (minutes < 60) return `Hace ${minutes} min`
  if (hours < 24) return `Hace ${hours}h`
  if (days < 7) return `Hace ${days} día${days > 1 ? 's' : ''}`
  
  return d.toLocaleDateString('es-MX', { 
    day: 'numeric', 
    month: 'short',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const formatShortDate = (date: string) => {
  if (!date) return ''
  return new Date(date).toLocaleDateString('es-MX', { 
    day: 'numeric', 
    month: 'short' 
  })
}

// Cargar al montar y cuando cambie taskId
watch(() => props.taskId, () => {
  if (props.taskId) loadActivities()
}, { immediate: true })

// Exponer refresh para llamar desde el padre
defineExpose({ refresh: loadActivities })
</script>