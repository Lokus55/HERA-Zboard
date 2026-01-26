<template>
  <div class="min-h-screen flex flex-col md:flex-row bg-neutral-950 text-white">
    <!-- Mobile Header -->
    <header class="md:hidden flex items-center justify-between p-4 border-b border-neutral-800 bg-neutral-950 sticky top-0 z-40">
      <div class="flex items-center gap-2">
        <div class="w-8 h-8 rounded-lg bg-gradient-to-br from-cyan-400 to-cyan-600 flex items-center justify-center">
          <span class="text-neutral-950 font-bold text-sm">Z</span>
        </div>
        <span class="font-bold">Zboard</span>
      </div>
      <div class="flex items-center gap-2">
        <AppNotificationBell />
        <button @click="isMobileMenuOpen = !isMobileMenuOpen" class="p-2 text-neutral-400">
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path v-if="!isMobileMenuOpen" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16m-7 6h7" />
            <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>
    </header>

    <!-- Sidebar -->
    <aside 
      :class="[
        'fixed inset-y-0 left-0 z-50 w-64 border-r border-neutral-800 bg-neutral-950 p-4 flex flex-col transition-transform duration-300 transform md:relative md:translate-x-0',
        isMobileMenuOpen ? 'translate-x-0' : '-translate-x-full'
      ]"
    >
      <div class="hidden md:flex items-center gap-3 mb-6">
        <div class="w-8 h-8 rounded-lg bg-gradient-to-br from-cyan-400 to-cyan-600 flex items-center justify-center">
          <span class="text-neutral-950 font-bold text-sm">Z</span>
        </div>
        <span class="font-bold">Zboard</span>
      </div>

      <!-- Workspace Selector -->
      <div class="mb-4">
        <label class="block text-xs font-medium text-neutral-500 uppercase mb-2 px-1">Workspace</label>
        <button @click="showWorkspaceDropdown = !showWorkspaceDropdown" class="w-full flex items-center justify-between p-3 bg-neutral-900 rounded-lg hover:bg-neutral-800 transition-colors">
          <div class="flex items-center gap-3 min-w-0">
            <div class="w-7 h-7 rounded-lg flex items-center justify-center text-white font-bold text-xs" :style="{ backgroundColor: currentWorkspace?.color || '#06b6d4' }">
              {{ currentWorkspace?.name?.charAt(0) || 'W' }}
            </div>
            <span class="font-medium truncate text-sm">{{ currentWorkspace?.name || 'Seleccionar' }}</span>
          </div>
          <svg class="w-4 h-4 text-neutral-400 flex-shrink-0 transition-transform" :class="{ 'rotate-180': showWorkspaceDropdown }" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
          </svg>
        </button>
        
        <!-- Workspace Dropdown -->
        <div v-if="showWorkspaceDropdown" class="mt-2 bg-neutral-900 border border-neutral-800 rounded-lg overflow-hidden shadow-lg">
          <button 
            v-for="ws in workspaces" 
            :key="ws.id" 
            @click="switchWorkspace(ws)" 
            class="w-full flex items-center gap-3 p-3 hover:bg-neutral-800 transition-colors"
            :class="{ 'bg-neutral-800': currentWorkspace?.id === ws.id }"
          >
            <div class="w-6 h-6 rounded flex items-center justify-center text-white font-bold text-xs" :style="{ backgroundColor: ws.color || '#06b6d4' }">
              {{ ws.name?.charAt(0) }}
            </div>
            <span class="text-sm truncate flex-1 text-left">{{ ws.name }}</span>
            <svg v-if="currentWorkspace?.id === ws.id" class="w-4 h-4 text-cyan-400" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
            </svg>
          </button>
          <div class="border-t border-neutral-800">
            <button @click="openNewWorkspace" class="w-full flex items-center gap-3 p-3 text-cyan-400 hover:bg-neutral-800 transition-colors">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 4v16m8-8H4" />
              </svg>
              <span class="text-sm">Nuevo workspace</span>
            </button>
          </div>
        </div>
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

        <button @click="showNewProject = true; isMobileMenuOpen = false" class="sidebar-item w-full text-left text-cyan-400">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 4v16m8-8H4" />
          </svg>
          Nuevo proyecto
        </button>
      </nav>

      <div class="pt-4 border-t border-neutral-800 space-y-1">
        <button @click="showWorkspaceSettings = true" class="sidebar-item w-full text-left text-neutral-400 hover:text-white">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
          </svg>
          Configuración
        </button>
        <button @click="handleLogout" class="sidebar-item w-full text-left text-red-400 hover:text-red-300">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
          </svg>
          Cerrar sesión
        </button>
      </div>
    </aside>

    <!-- Overlay móvil -->
    <div v-if="isMobileMenuOpen" @click="isMobileMenuOpen = false" class="fixed inset-0 bg-black/50 z-40 md:hidden" />

    <!-- Main Content -->
    <main class="flex-1 p-4 md:p-8 overflow-y-auto">
      <div class="flex items-center justify-between mb-8">
        <div>
          <h1 class="text-xl md:text-2xl font-bold">{{ currentWorkspace?.name || 'Dashboard' }}</h1>
          <p class="text-neutral-400 text-sm">{{ projects.length }} proyecto(s)</p>
        </div>
        <div class="hidden md:block">
          <AppNotificationBell />
        </div>
      </div>

      <!-- Stats -->
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

      <!-- Projects -->
      <h2 class="text-lg font-semibold mb-4">Proyectos</h2>
      
      <div v-if="loading" class="text-neutral-400 italic">Cargando...</div>
      
      <div v-else-if="projects.length === 0" class="card p-8 text-center">
        <p class="text-neutral-400 mb-4">No tienes proyectos en este workspace</p>
        <button @click="showNewProject = true" class="btn-primary w-full sm:w-auto">
          Crear primer proyecto
        </button>
      </div>

      <div v-else class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        <NuxtLink 
          v-for="project in projects" 
          :key="project.id"
          :to="`/project/${project.id}`"
          class="card p-4 md:p-6 hover:border-neutral-700 transition-all hover:scale-[1.02] active:scale-[0.98]"
        >
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-lg shrink-0 flex items-center justify-center text-white font-bold" :style="{ backgroundColor: project.color || '#06b6d4' }">
              {{ project.name.charAt(0) }}
            </div>
            <div class="flex-1 min-w-0">
              <h3 class="font-semibold truncate text-sm md:text-base">{{ project.name }}</h3>
              <p class="text-xs text-neutral-500">{{ formatDate(project.created_at) }}</p>
            </div>
          </div>
        </NuxtLink>
      </div>
    </main>

    <!-- Modal Nuevo Workspace -->
    <div v-if="showNewWorkspace" class="fixed inset-0 bg-black/60 flex items-end sm:items-center justify-center p-0 sm:p-4 z-[60]">
      <div class="card p-6 w-full max-w-md rounded-t-2xl sm:rounded-xl">
        <div class="flex items-center justify-between mb-4">
          <h2 class="text-xl font-bold">Nuevo workspace</h2>
          <button @click="showNewWorkspace = false" class="p-2 -mr-2 text-neutral-400 hover:text-white">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
        <form @submit.prevent="createWorkspace" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5">Nombre</label>
            <input v-model="workspaceForm.name" type="text" class="input" placeholder="Mi empresa, Equipo..." required>
          </div>
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5">Color</label>
            <div class="flex flex-wrap gap-3">
              <button
                v-for="color in colors"
                :key="color"
                type="button"
                @click="workspaceForm.color = color"
                class="w-10 h-10 sm:w-8 sm:h-8 rounded-lg transition-transform hover:scale-110"
                :class="{ 'ring-2 ring-white ring-offset-2 ring-offset-neutral-900': workspaceForm.color === color }"
                :style="{ backgroundColor: color }"
              />
            </div>
          </div>
          <div class="flex flex-col-reverse sm:flex-row gap-3 pt-2">
            <button type="button" @click="showNewWorkspace = false" class="btn-secondary w-full">Cancelar</button>
            <button type="submit" class="btn-primary w-full">Crear workspace</button>
          </div>
        </form>
      </div>
    </div>

    <!-- Modal Nuevo Proyecto -->
    <div v-if="showNewProject" class="fixed inset-0 bg-black/60 flex items-end sm:items-center justify-center p-0 sm:p-4 z-[60]">
      <div class="card p-6 w-full max-w-md rounded-t-2xl sm:rounded-xl">
        <div class="flex items-center justify-between mb-4">
          <h2 class="text-xl font-bold">Nuevo proyecto</h2>
          <button @click="showNewProject = false" class="p-2 -mr-2 text-neutral-400 hover:text-white">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
        <form @submit.prevent="createProject" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5">Nombre</label>
            <input v-model="projectForm.name" type="text" class="input" placeholder="Mi proyecto" required>
          </div>
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5">Descripción (opcional)</label>
            <textarea v-model="projectForm.description" class="input" rows="2" placeholder="¿De qué trata?"></textarea>
          </div>
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5">Color</label>
            <div class="flex flex-wrap gap-3">
              <button
                v-for="color in colors"
                :key="color"
                type="button"
                @click="projectForm.color = color"
                class="w-10 h-10 sm:w-8 sm:h-8 rounded-lg transition-transform hover:scale-110"
                :class="{ 'ring-2 ring-white ring-offset-2 ring-offset-neutral-900': projectForm.color === color }"
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

    <!-- Modal Configuración Workspace -->
    <div v-if="showWorkspaceSettings" class="fixed inset-0 bg-black/60 flex items-end sm:items-center justify-center p-0 sm:p-4 z-[60]">
      <div class="card p-6 w-full max-w-md rounded-t-2xl sm:rounded-xl max-h-[90vh] overflow-y-auto">
        <div class="flex items-center justify-between mb-4">
          <h2 class="text-xl font-bold">Configuración</h2>
          <button @click="showWorkspaceSettings = false" class="p-2 -mr-2 text-neutral-400 hover:text-white">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
        <form @submit.prevent="updateWorkspace" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5">Nombre del workspace</label>
            <input v-model="workspaceSettingsForm.name" type="text" class="input" required>
          </div>
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5">Color</label>
            <div class="flex flex-wrap gap-3">
              <button
                v-for="color in colors"
                :key="color"
                type="button"
                @click="workspaceSettingsForm.color = color"
                class="w-10 h-10 sm:w-8 sm:h-8 rounded-lg transition-transform hover:scale-110"
                :class="{ 'ring-2 ring-white ring-offset-2 ring-offset-neutral-900': workspaceSettingsForm.color === color }"
                :style="{ backgroundColor: color }"
              />
            </div>
          </div>
          
          <!-- Miembros -->
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-2">Miembros ({{ workspaceMembers.length }})</label>
            <div class="space-y-2 max-h-40 overflow-y-auto">
              <div v-for="member in workspaceMembers" :key="member.user_id" class="flex items-center justify-between p-2 bg-neutral-800 rounded-lg">
                <div class="flex items-center gap-2 min-w-0">
                  <div class="w-7 h-7 rounded-full bg-cyan-500 flex items-center justify-center text-xs text-white flex-shrink-0">
                    {{ member.full_name?.charAt(0) || member.email?.charAt(0) || '?' }}
                  </div>
                  <span class="text-sm truncate">{{ member.full_name || member.email }}</span>
                </div>
                <span class="text-xs text-neutral-500 capitalize flex-shrink-0 ml-2">{{ member.role }}</span>
              </div>
            </div>
          </div>

          <div class="flex flex-col-reverse sm:flex-row gap-3 pt-2">
            <button 
              v-if="workspaces.length > 1 && currentWorkspace?.role === 'owner'" 
              type="button" 
              @click="deleteWorkspace" 
              class="btn-secondary text-red-400 hover:text-red-300"
            >
              Eliminar workspace
            </button>
            <div class="flex-1"></div>
            <button type="button" @click="showWorkspaceSettings = false" class="btn-secondary">Cancelar</button>
            <button type="submit" class="btn-primary">Guardar</button>
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

// UI State
const isMobileMenuOpen = ref(false)
const showWorkspaceDropdown = ref(false)
const showNewWorkspace = ref(false)
const showNewProject = ref(false)
const showWorkspaceSettings = ref(false)

// Data
const loading = ref(true)
const creating = ref(false)
const createError = ref('')
const workspaces = ref<any[]>([])
const currentWorkspace = ref<any>(null)
const workspaceMembers = ref<any[]>([])
const projects = ref<any[]>([])
const taskStats = ref({ pending: 0, completed: 0 })

// Forms
const colors = ['#06b6d4', '#8b5cf6', '#f59e0b', '#10b981', '#ef4444', '#ec4899', '#6366f1']
const workspaceForm = ref({ name: '', color: '#06b6d4' })
const projectForm = ref({ name: '', description: '', color: '#06b6d4' })
const workspaceSettingsForm = ref({ name: '', color: '#06b6d4' })

// Helpers
const getUserId = (u: any): string | null => u?.id || u?.sub || null

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('es-MX', { day: 'numeric', month: 'short' })
}


// Load workspaces
const loadWorkspaces = async () => {
  const userId = getUserId(user.value)
  if (!userId) return
  
  const { data, error } = await supabase
    .from('workspace_members')
    .select('workspace_id, role, workspaces(id, name, color, owner_id)')
    .eq('user_id', userId)
  
  console.log('Workspaces data:', data) // Para debug
  console.log('Workspaces error:', error) // Para debug
  
  if (data && data.length > 0) {
    workspaces.value = data.map((m: any) => ({
      id: m.workspaces?.id,
      name: m.workspaces?.name,
      color: m.workspaces?.color || '#06b6d4',
      owner_id: m.workspaces?.owner_id,
      role: m.role
    })).filter((w: any) => w.id)
    
    // Restore last workspace or use first
    const lastWorkspaceId = localStorage.getItem('lastWorkspaceId')
    const lastWorkspace = workspaces.value.find(w => w.id === lastWorkspaceId)
    
    if (lastWorkspace) {
      currentWorkspace.value = lastWorkspace
    } else if (workspaces.value.length > 0) {
      currentWorkspace.value = workspaces.value[0]
      localStorage.setItem('lastWorkspaceId', currentWorkspace.value.id)
    }
    
    console.log('Current workspace:', currentWorkspace.value) // Para debug
  }
}

// Switch workspace
const switchWorkspace = (workspace: any) => {
  currentWorkspace.value = workspace
  localStorage.setItem('lastWorkspaceId', workspace.id)
  showWorkspaceDropdown.value = false
  isMobileMenuOpen.value = false
  loadProjects()
  loadWorkspaceMembers()
  loadTaskStats()
}

// Load projects for current workspace
const loadProjects = async () => {
  if (!currentWorkspace.value) {
    loading.value = false
    return
  }
  
  loading.value = true
  
  const { data } = await supabase
    .from('projects')
    .select('*')
    .eq('workspace_id', currentWorkspace.value.id)
    .order('created_at', { ascending: false })
  
  if (data) {
    projects.value = data
  }
  
  loading.value = false
}

// Load workspace members
const loadWorkspaceMembers = async () => {
  if (!currentWorkspace.value) return

  const { data } = await supabase
    .from('workspace_members')
    .select('user_id, role, profiles(email, full_name)')
    .eq('workspace_id', currentWorkspace.value.id)

  if (data) {
    workspaceMembers.value = data.map((m: any) => ({
      user_id: m.user_id,
      role: m.role,
      email: m.profiles?.email,
      full_name: m.profiles?.full_name
    }))
  }
}

// Load task stats
const loadTaskStats = async () => {
  if (projects.value.length === 0) {
    taskStats.value = { pending: 0, completed: 0 }
    return
  }
  
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

// Create workspace
const openNewWorkspace = () => {
  showWorkspaceDropdown.value = false
  workspaceForm.value = { name: '', color: '#06b6d4' }
  showNewWorkspace.value = true
}

const createWorkspace = async () => {
  const userId = getUserId(user.value)
  if (!userId || !workspaceForm.value.name.trim()) return

  // Generar slug desde el nombre
  const slug = workspaceForm.value.name
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '')

  const { data: workspace, error } = await supabase
    .from('workspaces')
    .insert({
      name: workspaceForm.value.name,
      color: workspaceForm.value.color,
      owner_id: userId,
      slug: slug  // Agregar el slug
    })
    .select()
    .single()

  if (!error && workspace) {
    await supabase.from('workspace_members').insert({
      workspace_id: workspace.id,
      user_id: userId,
      role: 'owner'
    })

    const newWs = { ...workspace, role: 'owner' }
    workspaces.value.push(newWs)
    switchWorkspace(newWs)
    showNewWorkspace.value = false
  }
}

// Update workspace
const updateWorkspace = async () => {
  if (!currentWorkspace.value) return

  const { error } = await supabase
    .from('workspaces')
    .update({
      name: workspaceSettingsForm.value.name,
      color: workspaceSettingsForm.value.color
    })
    .eq('id', currentWorkspace.value.id)

  if (!error) {
    currentWorkspace.value.name = workspaceSettingsForm.value.name
    currentWorkspace.value.color = workspaceSettingsForm.value.color
    
    const idx = workspaces.value.findIndex(w => w.id === currentWorkspace.value.id)
    if (idx > -1) {
      workspaces.value[idx] = { ...workspaces.value[idx], ...workspaceSettingsForm.value }
    }
    
    showWorkspaceSettings.value = false
  }
}

// Delete workspace
const deleteWorkspace = async () => {
  if (!currentWorkspace.value || workspaces.value.length <= 1) return
  
  if (!confirm(`¿Eliminar "${currentWorkspace.value.name}"? Se eliminarán todos los proyectos y tareas.`)) return

  const { error } = await supabase
    .from('workspaces')
    .delete()
    .eq('id', currentWorkspace.value.id)

  if (!error) {
    workspaces.value = workspaces.value.filter(w => w.id !== currentWorkspace.value.id)
    switchWorkspace(workspaces.value[0])
    showWorkspaceSettings.value = false
  }
}

// Create project
const createProject = async () => {
  if (!currentWorkspace.value || !projectForm.value.name.trim()) return
  
  creating.value = true
  createError.value = ''
  
  const userId = getUserId(user.value)
  
  const { data: project, error } = await supabase
    .from('projects')
    .insert({
      name: projectForm.value.name,
      description: projectForm.value.description,
      color: projectForm.value.color,
      workspace_id: currentWorkspace.value.id,
      created_by: userId
    })
    .select()
    .single()
  
  if (error) {
    createError.value = error.message
    creating.value = false
    return
  }
  
  if (project) {
    // ELIMINA ESTE BLOQUE - Ya no crear columnas manualmente
    // const defaultStatuses = [...]
    // await supabase.from('task_statuses').insert(...)

    projects.value.unshift(project)
    showNewProject.value = false
    projectForm.value = { name: '', description: '', color: '#06b6d4' }
    navigateTo(`/project/${project.id}`)
  }
  
  creating.value = false
}

// Watch for settings modal
watch(showWorkspaceSettings, (val) => {
  if (val && currentWorkspace.value) {
    workspaceSettingsForm.value = {
      name: currentWorkspace.value.name,
      color: currentWorkspace.value.color || '#06b6d4'
    }
    loadWorkspaceMembers()
  }
})

// Logout
const handleLogout = async () => {
  await supabase.auth.signOut()
  navigateTo('/')
}

// Initial load
watch(() => user.value, async (newUser) => {
  const userId = getUserId(newUser)
  if (userId) {
    await loadWorkspaces()
    if (currentWorkspace.value) {
      await loadProjects()
      await loadWorkspaceMembers()
      await loadTaskStats()
    } else {
      loading.value = false
    }
  }
}, { immediate: true })
</script>