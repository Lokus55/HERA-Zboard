<template>
  <div class="min-h-screen flex">
    <!-- Sidebar -->
    <aside class="w-64 border-r border-neutral-800 p-4 flex flex-col">
      <div class="flex items-center gap-3 mb-8">
        <div class="w-8 h-8 rounded-lg bg-gradient-to-br from-cyan-400 to-cyan-600 flex items-center justify-center">
          <span class="text-neutral-950 font-bold text-sm">Z</span>
        </div>
        <span class="font-bold">Zboard</span>
      </div>

      <nav class="flex-1 space-y-1">
        <NuxtLink to="/dashboard" class="sidebar-item sidebar-item-active">
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
        >
          <div class="w-2 h-2 rounded-full" :style="{ backgroundColor: project.color || '#06b6d4' }" />
          {{ project.name }}
        </NuxtLink>

        <button @click="showNewProject = true" class="sidebar-item w-full text-left">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 4v16m8-8H4" />
          </svg>
          Nuevo proyecto
        </button>
      </nav>

      <button @click="handleLogout" class="sidebar-item text-red-400 hover:text-red-300">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
        </svg>
        Cerrar sesión
      </button>
    </aside>

    <!-- Main -->
    <main class="flex-1 p-8">
      <div class="mb-8">
        <h1 class="text-2xl font-bold">Dashboard</h1>
        <p class="text-neutral-400">{{ workspaceName }}</p>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <div class="card p-6">
          <p class="text-3xl font-bold">{{ projects.length }}</p>
          <p class="text-neutral-400">Proyectos</p>
        </div>
        <div class="card p-6">
          <p class="text-3xl font-bold">0</p>
          <p class="text-neutral-400">Tareas pendientes</p>
        </div>
        <div class="card p-6">
          <p class="text-3xl font-bold">0</p>
          <p class="text-neutral-400">Completadas</p>
        </div>
      </div>

      <h2 class="text-lg font-semibold mb-4">Proyectos recientes</h2>
      
      <div v-if="loading" class="text-neutral-400">Cargando...</div>
      
      <div v-else-if="projects.length === 0" class="card p-8 text-center">
        <p class="text-neutral-400 mb-4">No tienes proyectos aún</p>
        <button @click="showNewProject = true" class="btn-primary">
          Crear primer proyecto
        </button>
      </div>

      <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <NuxtLink 
          v-for="project in projects" 
          :key="project.id"
          :to="`/project/${project.id}`"
          class="card p-6 hover:border-neutral-700 transition-colors"
        >
          <div class="flex items-center gap-3 mb-3">
            <div class="w-10 h-10 rounded-lg flex items-center justify-center text-white font-bold" :style="{ backgroundColor: project.color || '#06b6d4' }">
              {{ project.name.charAt(0) }}
            </div>
            <h3 class="font-semibold">{{ project.name }}</h3>
          </div>
        </NuxtLink>
      </div>
    </main>

    <!-- Modal Nuevo Proyecto -->
    <div v-if="showNewProject" class="fixed inset-0 bg-black/60 flex items-center justify-center p-4 z-50">
      <div class="card p-6 w-full max-w-md">
        <h2 class="text-xl font-bold mb-4">Nuevo proyecto</h2>
        <form @submit.prevent="createProject" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5">Nombre</label>
            <input v-model="newProjectName" type="text" class="input" placeholder="Mi proyecto" required>
          </div>
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5">Color</label>
            <div class="flex gap-2">
              <button
                v-for="color in colors"
                :key="color"
                type="button"
                @click="newProjectColor = color"
                class="w-8 h-8 rounded-lg transition-transform hover:scale-110"
                :class="{ 'ring-2 ring-white': newProjectColor === color }"
                :style="{ backgroundColor: color }"
              />
            </div>
          </div>
          <div v-if="createError" class="text-red-400 text-sm">{{ createError }}</div>
          <div class="flex gap-3 pt-2">
            <button type="button" @click="showNewProject = false" class="btn-secondary flex-1">Cancelar</button>
            <button type="submit" class="btn-primary flex-1" :disabled="creating">
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

const showNewProject = ref(false)
const newProjectName = ref('')
const newProjectColor = ref('#06b6d4')
const colors = ['#06b6d4', '#8b5cf6', '#f59e0b', '#10b981', '#ef4444', '#ec4899']

const loading = ref(true)
const creating = ref(false)
const createError = ref('')
const projects = ref<any[]>([])
const workspaceId = ref<string | null>(null)
const workspaceName = ref('Cargando...')

// Obtener el ID del usuario (puede ser .id o .sub dependiendo del contexto)
const getUserId = (u: any): string | null => {
  if (!u) return null
  return u.id || u.sub || null
}

// Cargar datos
const loadData = async (userId: string) => {
  console.log('Loading data for user:', userId)
  loading.value = true
  
  try {
    // Paso 1: Obtener workspace_id del usuario
    console.log('Fetching workspace_members...')
    const { data: memberData, error: memberError } = await supabase
      .from('workspace_members')
      .select('workspace_id')
      .eq('user_id', userId)
      .single()
    
    console.log('Member data:', memberData, 'Error:', memberError)
    
    if (memberError || !memberData) {
      workspaceName.value = 'Sin workspace'
      loading.value = false
      return
    }
    
    workspaceId.value = memberData.workspace_id
    
    // Paso 2: Obtener nombre del workspace
    const { data: wsData } = await supabase
      .from('workspaces')
      .select('name')
      .eq('id', memberData.workspace_id)
      .single()
    
    console.log('Workspace data:', wsData)
    
    if (wsData) {
      workspaceName.value = wsData.name
    }
    
    // Paso 3: Cargar proyectos del workspace
    const { data: projectsData } = await supabase
      .from('projects')
      .select('*')
      .eq('workspace_id', memberData.workspace_id)
      .order('created_at', { ascending: false })
    
    console.log('Projects data:', projectsData)
    
    if (projectsData) {
      projects.value = projectsData
    }
  } catch (e) {
    console.error('Error loading data:', e)
  }
  
  loading.value = false
}

// Crear proyecto
const createProject = async () => {
  const userId = getUserId(user.value)
  if (!newProjectName.value.trim() || !workspaceId.value || !userId) return
  
  creating.value = true
  createError.value = ''
  
  const { data, error } = await supabase
    .from('projects')
    .insert({
      name: newProjectName.value,
      color: newProjectColor.value,
      workspace_id: workspaceId.value,
      created_by: userId
    })
    .select()
    .single()
  
  if (error) {
    console.error('Error creating project:', error)
    createError.value = error.message
    creating.value = false
    return
  }
  
  if (data) {
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

// Cargar cuando el componente se monta
onMounted(async () => {
  const userId = getUserId(user.value)
  console.log('Component mounted, userId:', userId)
  
  if (userId) {
    await loadData(userId)
  }
})

// También observar cambios en el usuario
watch(() => user.value, async (newUser) => {
  const userId = getUserId(newUser)
  console.log('User changed, userId:', userId)
  
  if (userId && loading.value) {
    await loadData(userId)
  }
}, { immediate: true })
</script>