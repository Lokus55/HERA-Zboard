<template>
  <div class="min-h-screen flex flex-col md:flex-row bg-neutral-950 text-white">
    <header class="md:hidden flex items-center justify-between p-4 border-b border-neutral-800 bg-neutral-950 sticky top-0 z-40">
      <div class="flex items-center gap-2">
        <div class="w-8 h-8 rounded-lg bg-gradient-to-br from-cyan-400 to-cyan-600 flex items-center justify-center">
          <span class="text-neutral-950 font-bold text-sm">F</span>
        </div>
        <span class="font-bold">Flowboard</span>
      </div>
      <button @click="isMobileMenuOpen = !isMobileMenuOpen" class="p-2 text-neutral-400">
        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path v-if="!isMobileMenuOpen" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16m-7 6h7" />
          <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
        </svg>
      </button>
    </header>

    <aside 
      :class="[
        'fixed inset-y-0 left-0 z-50 w-64 border-r border-neutral-800 bg-neutral-950 p-4 flex flex-col transition-transform duration-300 transform md:relative md:translate-x-0',
        isMobileMenuOpen ? 'translate-x-0' : '-translate-x-full'
      ]"
    >
      <div class="hidden md:flex items-center gap-3 mb-8">
        <div class="w-8 h-8 rounded-lg bg-gradient-to-br from-cyan-400 to-cyan-600 flex items-center justify-center">
          <span class="text-neutral-950 font-bold text-sm">Z</span>
        </div>
        <span class="font-bold">Zboard</span>
      </div>

      <nav class="flex-1 space-y-1 overflow-y-auto">
        <NuxtLink to="/dashboard" class="sidebar-item sidebar-item-active" @click="isMobileMenuOpen = false">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
          </svg>
          Dashboard
        </NuxtLink>

        <div class="pt-4 pb-2">
          <span class="px-3 text-xs font-medium text-neutral-500 uppercase">Proyectos</span>
        </div>

        <NuxtLink 
          v-for="project in projects" 
          :key="project.id"
          :to="`/project/${project.id}`"
          class="sidebar-item"
          @click="isMobileMenuOpen = false"
        >
          <div class="w-2 h-2 rounded-full shrink-0" :style="{ backgroundColor: project.color || '#06b6d4' }" />
          <span class="truncate">{{ project.name }}</span>
        </NuxtLink>

        <button @click="showNewProject = true; isMobileMenuOpen = false" class="sidebar-item w-full text-left">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 4v16m8-8H4" />
          </svg>
          Nuevo proyecto
        </button>
      </nav>

      <button @click="handleLogout" class="sidebar-item text-red-400 hover:text-red-300 mt-auto">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
        </svg>
        Cerrar sesión
      </button>
    </aside>

    <div v-if="isMobileMenuOpen" @click="isMobileMenuOpen = false" class="fixed inset-0 bg-black/50 z-40 md:hidden" />

    <main class="flex-1 p-4 md:p-8 overflow-y-auto">
      <div class="flex items-center justify-between mb-8">
        <div>
          <h1 class="text-xl md:text-2xl font-bold">Dashboard</h1>
          <p class="text-neutral-400 text-sm">{{ workspaces.length }} workspace(s)</p>
        </div>
        <AppNotificationBell />
      </div>

      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 mb-8">
        <div class="card p-4 md:p-6">
          <p class="text-2xl md:text-3xl font-bold">{{ projects.length }}</p>
          <p class="text-neutral-400 text-sm">Proyectos</p>
        </div>
        <div class="card p-4 md:p-6">
          <p class="text-2xl md:text-3xl font-bold">{{ taskStats.pending }}</p>
          <p class="text-neutral-400 text-sm">Tareas pendientes</p>
        </div>
        <div class="card p-4 md:p-6 sm:col-span-2 lg:col-span-1">
          <p class="text-2xl md:text-3xl font-bold">{{ taskStats.completed }}</p>
          <p class="text-neutral-400 text-sm">Completadas</p>
        </div>
      </div>

      <h2 class="text-lg font-semibold mb-4">Proyectos recientes</h2>
      
      <div v-if="loading" class="text-neutral-400 italic">Cargando...</div>
      
      <div v-else-if="projects.length === 0" class="card p-8 text-center">
        <p class="text-neutral-400 mb-4">No tienes proyectos aún</p>
        <button @click="showNewProject = true" class="btn-primary w-full sm:w-auto">
          Crear primer proyecto
        </button>
      </div>

      <div v-else class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        <NuxtLink 
          v-for="project in projects" 
          :key="project.id"
          :to="`/project/${project.id}`"
          class="card p-4 md:p-6 hover:border-neutral-700 transition-colors"
        >
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-lg shrink-0 flex items-center justify-center text-white font-bold" :style="{ backgroundColor: project.color || '#06b6d4' }">
              {{ project.name.charAt(0) }}
            </div>
            <div class="flex-1 min-w-0">
              <h3 class="font-semibold truncate text-sm md:text-base">{{ project.name }}</h3>
              <p class="text-xs text-neutral-500 truncate">{{ project.workspace_name }}</p>
            </div>
          </div>
        </NuxtLink>
      </div>
    </main>

    <div v-if="showNewProject" class="fixed inset-0 bg-black/60 flex items-end sm:items-center justify-center p-0 sm:p-4 z-[60]">
      <div class="card p-6 w-full max-w-md rounded-t-2xl sm:rounded-xl">
        <h2 class="text-xl font-bold mb-4">Nuevo proyecto</h2>
        <form @submit.prevent="createProject" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5">Nombre</label>
            <input v-model="newProjectName" type="text" class="input" placeholder="Mi proyecto" required>
          </div>
          <div v-if="workspaces.length > 1">
            <label class="block text-sm font-medium text-neutral-400 mb-1.5">Workspace</label>
            <select v-model="selectedWorkspaceId" class="input">
              <option v-for="ws in workspaces" :key="ws.id" :value="ws.id">{{ ws.name }}</option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5">Color</label>
            <div class="flex flex-wrap gap-3">
              <button
                v-for="color in colors"
                :key="color"
                type="button"
                @click="newProjectColor = color"
                class="w-10 h-10 sm:w-8 sm:h-8 rounded-lg transition-transform hover:scale-110"
                :class="{ 'ring-2 ring-white ring-offset-2 ring-offset-neutral-900': newProjectColor === color }"
                :style="{ backgroundColor: color }"
              />
            </div>
          </div>
          <div v-if="createError" class="text-red-400 text-sm">{{ createError }}</div>
          <div class="flex flex-col-reverse sm:flex-row gap-3 pt-2">
            <button type="button" @click="showNewProject = false" class="btn-secondary w-full">Cancelar</button>
            <button type="submit" class="btn-primary w-full" :disabled="creating">
              {{ creating ? 'Creando...' : 'Crear' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ middleware: 'auth' })

const supabase = useSupabaseClient()
const user = useSupabaseUser()

const isMobileMenuOpen = ref(false) // Control del sidebar en móvil
const showNewProject = ref(false)
const newProjectName = ref('')
const newProjectColor = ref('#06b6d4')
const selectedWorkspaceId = ref<string | null>(null)
const colors = ['#06b6d4', '#8b5cf6', '#f59e0b', '#10b981', '#ef4444', '#ec4899']

const loading = ref(true)
const creating = ref(false)
const createError = ref('')
const projects = ref<any[]>([])
const workspaces = ref<any[]>([])
const taskStats = ref({ pending: 0, completed: 0 })

// ... (El resto de tu lógica de script se mantiene igual)

const getUserId = (u: any): string | null => {
  if (!u) return null
  return u.id || u.sub || null
}

const loadWorkspaces = async () => {
  const userId = getUserId(user.value)
  if (!userId) return
  
  const { data } = await supabase
    .from('workspace_members')
    .select('workspace_id, role, workspaces(id, name)')
    .eq('user_id', userId)
  
  if (data) {
    workspaces.value = data.map((m: any) => ({
      id: m.workspaces?.id,
      name: m.workspaces?.name,
      role: m.role
    })).filter((w: any) => w.id)
    
    if (workspaces.value.length > 0 && !selectedWorkspaceId.value) {
      selectedWorkspaceId.value = workspaces.value[0].id
    }
  }
}

const loadProjects = async () => {
  if (workspaces.value.length === 0) {
    loading.value = false
    return
  }
  
  const workspaceIds = workspaces.value.map(w => w.id)
  
  const { data } = await supabase
    .from('projects')
    .select('*, workspaces(name)')
    .in('workspace_id', workspaceIds)
    .order('created_at', { ascending: false })
  
  if (data) {
    projects.value = data.map((p: any) => ({
      ...p,
      workspace_name: p.workspaces?.name || 'Workspace'
    }))
  }
  
  loading.value = false
}

const loadTaskStats = async () => {
  if (projects.value.length === 0) return
  
  const projectIds = projects.value.map(p => p.id)
  
  const { data: statuses } = await supabase
    .from('task_statuses')
    .select('id, name')
    .in('project_id', projectIds)
  
  const completedStatusIds = statuses
    ?.filter(s => s.name.toLowerCase().includes('completado') || s.name.toLowerCase().includes('done'))
    .map(s => s.id) || []
  
  const { data: tasks } = await supabase
    .from('tasks')
    .select('id, status_id')
    .in('project_id', projectIds)
  
  if (tasks) {
    taskStats.value = {
      completed: tasks.filter(t => completedStatusIds.includes(t.status_id)).length,
      pending: tasks.filter(t => !completedStatusIds.includes(t.status_id)).length
    }
  }
}

const createProject = async () => {
  if (!newProjectName.value.trim() || !selectedWorkspaceId.value) return
  
  creating.value = true
  createError.value = ''
  
  const userId = getUserId(user.value)
  
  const { data, error } = await supabase
    .from('projects')
    .insert({
      name: newProjectName.value,
      color: newProjectColor.value,
      workspace_id: selectedWorkspaceId.value,
      created_by: userId
    })
    .select('*, workspaces(name)')
    .single()
  
  if (error) {
    createError.value = error.message
    creating.value = false
    return
  }
  
  if (data) {
    data.workspace_name = data.workspaces?.name || 'Workspace'
    projects.value.unshift(data)
    showNewProject.value = false
    newProjectName.value = ''
    navigateTo(`/project/${data.id}`)
  }
  
  creating.value = false
}

const handleLogout = async () => {
  await supabase.auth.signOut()
  navigateTo('/')
}

watch(() => user.value, async (newUser) => {
  const userId = getUserId(newUser)
  if (userId) {
    await loadWorkspaces()
    await loadProjects()
    await loadTaskStats()
  }
}, { immediate: true })
</script>