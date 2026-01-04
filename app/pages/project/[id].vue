<template>
  <div class="min-h-screen flex flex-col lg:flex-row">
    <!-- Mobile Header -->
    <header class="lg:hidden border-b border-neutral-800 p-4 flex items-center justify-between">
      <button @click="sidebarOpen = true" class="p-2 -ml-2">
        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M4 6h16M4 12h16M4 18h16" />
        </svg>
      </button>
      <div class="flex items-center gap-2">
        <div 
          class="w-8 h-8 rounded-lg flex items-center justify-center text-neutral-950 font-bold text-sm"
          :style="{ backgroundColor: project?.color || '#06b6d4' }"
        >
          {{ project?.name?.charAt(0) || 'P' }}
        </div>
        <span class="font-semibold truncate max-w-[150px]">{{ project?.name }}</span>
      </div>
      <button @click="openNewTask" class="p-2 -mr-2 text-cyan-400">
        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
        </svg>
      </button>
    </header>

    <!-- Sidebar Overlay (Mobile) -->
    <div 
      v-if="sidebarOpen" 
      class="fixed inset-0 bg-black/60 z-40 lg:hidden"
      @click="sidebarOpen = false"
    />

    <!-- Sidebar -->
    <aside 
      class="fixed lg:relative inset-y-0 left-0 z-50 w-72 lg:w-64 border-r border-neutral-800 p-4 flex flex-col bg-neutral-950 transform transition-transform duration-300 lg:transform-none"
      :class="sidebarOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'"
    >
      <div class="flex items-center justify-between mb-8">
        <NuxtLink to="/dashboard" class="flex items-center gap-3">
          <div class="w-8 h-8 rounded-lg bg-gradient-to-br from-cyan-400 to-cyan-600 flex items-center justify-center">
            <span class="text-neutral-950 font-bold text-sm">F</span>
          </div>
          <span class="font-bold">Flowboard</span>
        </NuxtLink>
        <button @click="sidebarOpen = false" class="lg:hidden p-2 -mr-2">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>

      <nav class="flex-1 space-y-1 overflow-y-auto">
        <NuxtLink to="/dashboard" class="sidebar-item" @click="sidebarOpen = false">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
          </svg>
          Volver al Dashboard
        </NuxtLink>

        <!-- Filtro por usuario -->
        <div class="pt-4 pb-2">
          <span class="px-3 text-xs font-medium text-neutral-500 uppercase">Filtrar por</span>
        </div>
        
        <button 
          @click="filterByUser = null; sidebarOpen = false" 
          class="sidebar-item w-full text-left"
          :class="{ 'sidebar-item-active': filterByUser === null }"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z" />
          </svg>
          Todos
        </button>

        <div class="pt-2 pb-2">
          <span class="px-3 text-xs font-medium text-neutral-500 uppercase">Equipo</span>
        </div>

        <button
          v-for="member in members" 
          :key="member.user_id" 
          @click="filterByUser = member.user_id; sidebarOpen = false"
          class="sidebar-item w-full text-left group relative"
          :class="{ 'sidebar-item-active': filterByUser === member.user_id }"
        >
          <div 
            class="w-6 h-6 rounded-full flex items-center justify-center text-xs text-white flex-shrink-0"
            :style="{ backgroundColor: getAvatarColor(member.user_id) }"
          >
            {{ getInitials(member.full_name || member.email) }}
          </div>
          <span class="truncate">{{ member.full_name || member.email?.split('@')[0] }}</span>
          
          <!-- Tooltip (solo desktop) -->
          <div class="hidden lg:block absolute left-full ml-2 px-2 py-1 bg-neutral-800 rounded text-xs whitespace-nowrap opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none z-50">
            <div class="font-medium">{{ member.full_name || 'Sin nombre' }}</div>
            <div class="text-neutral-400">{{ member.email }}</div>
          </div>
        </button>

        <button @click="showInvite = true; sidebarOpen = false" class="sidebar-item w-full text-left text-cyan-400">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 4v16m8-8H4" />
          </svg>
          Invitar miembro
        </button>
      </nav>
    </aside>

    <!-- Main -->
    <main class="flex-1 flex flex-col overflow-hidden">
      <!-- Desktop Header -->
      <header class="hidden lg:block border-b border-neutral-800 p-4">
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-3">
            <div 
              class="w-10 h-10 rounded-lg flex items-center justify-center text-neutral-950 font-bold"
              :style="{ backgroundColor: project?.color || '#06b6d4' }"
            >
              {{ project?.name?.charAt(0) || 'P' }}
            </div>
            <div>
              <h1 class="text-xl font-bold">{{ project?.name || 'Cargando...' }}</h1>
              <p class="text-sm text-neutral-400">
                {{ filteredTasks.length }} tareas
                <span v-if="filterByUser" class="text-cyan-400">
                  · Filtrando por {{ getMemberName(filterByUser) }}
                </span>
              </p>
            </div>
          </div>
          <div class="flex gap-2">
            <button @click="showAddColumn = true" class="btn-secondary">
              + Columna
            </button>
            <button @click="openNewTask" class="btn-primary">
              + Nueva tarea
            </button>
          </div>
        </div>
      </header>

      <!-- Mobile Filter/Actions Bar -->
      <div class="lg:hidden border-b border-neutral-800 p-3 flex items-center gap-2 overflow-x-auto">
        <span class="text-xs text-neutral-500 flex-shrink-0">{{ filteredTasks.length }} tareas</span>
        <div class="flex-1" />
        <button @click="showAddColumn = true" class="btn-secondary text-sm py-1.5 px-3 flex-shrink-0">
          + Columna
        </button>
      </div>

      <!-- Kanban Board -->
      <div class="flex-1 overflow-x-auto p-4 lg:p-6">
        <div v-if="statuses.length === 0" class="text-neutral-400 text-center py-8">
          Cargando columnas...
        </div>
        <div v-else class="flex gap-3 lg:gap-4 h-full min-h-[400px]" :style="{ minWidth: `${statuses.length * 280}px` }">
          <div v-for="column in statuses" :key="column.id" class="w-[260px] sm:w-[280px] lg:w-80 flex-shrink-0">
            <div class="bg-neutral-900/50 rounded-xl p-2 sm:p-3 h-full flex flex-col">
              <div class="flex items-center justify-between mb-3 px-1">
                <div class="flex items-center gap-2">
                  <div class="w-2.5 h-2.5 lg:w-3 lg:h-3 rounded-full" :style="{ backgroundColor: column.color }" />
                  <h3 class="font-medium text-sm lg:text-base">{{ column.name }}</h3>
                  <span class="text-xs text-neutral-500 bg-neutral-800 px-1.5 py-0.5 rounded">
                    {{ getTasksByStatus(column.id).length }}
                  </span>
                </div>
                <button 
                  v-if="!isDefaultColumn(column.name)"
                  @click="editColumn(column)"
                  class="text-neutral-500 hover:text-neutral-300 p-1"
                >
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z" />
                  </svg>
                </button>
              </div>
              
              <draggable
                :list="getTasksByStatus(column.id)"
                group="tasks"
                item-key="id"
                class="flex-1 space-y-2 min-h-[100px] overflow-y-auto"
                @change="(e: any) => onDragChange(e, column.id)"
              >
                <template #item="{ element }">
                  <div
                    @click="openEditTask(element)"
                    class="card p-3 lg:p-4 cursor-pointer hover:border-neutral-700 transition-colors active:scale-[0.98]"
                  >
                    <h4 class="font-medium text-sm lg:text-base mb-2 line-clamp-2">{{ element.title }}</h4>
                    <div class="flex items-center justify-between">
                      <span 
                        class="text-xs px-2 py-0.5 rounded-full"
                        :class="priorityClass(element.priority)"
                      >
                        {{ priorityLabel(element.priority) }}
                      </span>
                      
                      <!-- Avatares de asignados -->
                      <div class="flex -space-x-1.5 lg:-space-x-2" v-if="element.assignees?.length">
                        <div
                          v-for="(assignee, idx) in element.assignees.slice(0, 3)"
                          :key="assignee.user_id"
                          class="w-5 h-5 lg:w-6 lg:h-6 rounded-full border-2 border-neutral-900 flex items-center justify-center text-[10px] lg:text-xs text-white cursor-pointer relative group"
                          :style="{ backgroundColor: getAvatarColor(assignee.user_id), zIndex: 3 - idx }"
                        >
                          {{ getInitials(assignee.full_name || assignee.email) }}
                          <!-- Tooltip (solo desktop) -->
                          <div class="hidden lg:block absolute bottom-full mb-1 left-1/2 -translate-x-1/2 px-2 py-1 bg-neutral-800 rounded text-xs whitespace-nowrap opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none z-50">
                            {{ assignee.full_name || assignee.email }}
                          </div>
                        </div>
                        <div
                          v-if="element.assignees.length > 3"
                          class="w-5 h-5 lg:w-6 lg:h-6 rounded-full border-2 border-neutral-900 bg-neutral-700 flex items-center justify-center text-[10px] lg:text-xs"
                        >
                          +{{ element.assignees.length - 3 }}
                        </div>
                      </div>
                    </div>
                  </div>
                </template>
              </draggable>

              <button 
                @click="addTaskToColumn(column.id)"
                class="w-full mt-2 p-2 text-sm text-neutral-500 hover:text-neutral-300 hover:bg-neutral-800 rounded-lg transition-colors"
              >
                + Añadir tarea
              </button>
            </div>
          </div>
        </div>
      </div>
    </main>

    <!-- Modal Nueva/Editar Tarea -->
    <div v-if="showTaskModal" class="fixed inset-0 bg-black/60 flex items-end sm:items-center justify-center p-0 sm:p-4 z-50">
      <div class="card p-4 sm:p-6 w-full sm:max-w-md max-h-[90vh] sm:max-h-[85vh] overflow-y-auto rounded-t-2xl sm:rounded-xl">
        <div class="flex items-center justify-between mb-4">
          <h2 class="text-lg sm:text-xl font-bold">{{ editingTask ? 'Editar tarea' : 'Nueva tarea' }}</h2>
          <button @click="closeTaskModal" class="p-2 -mr-2 text-neutral-400 hover:text-white">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
        <form @submit.prevent="saveTask" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5">Título</label>
            <input v-model="taskForm.title" type="text" class="input" placeholder="¿Qué hay que hacer?" required>
          </div>
          
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5">Descripción</label>
            <textarea v-model="taskForm.description" class="input" rows="3" placeholder="Detalles de la tarea..."></textarea>
          </div>

          <div class="grid grid-cols-2 gap-3 sm:gap-4">
            <div>
              <label class="block text-sm font-medium text-neutral-400 mb-1.5">Estado</label>
              <select v-model="taskForm.status_id" class="input text-sm">
                <option v-for="col in statuses" :key="col.id" :value="col.id">{{ col.name }}</option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-neutral-400 mb-1.5">Prioridad</label>
              <select v-model="taskForm.priority" class="input text-sm">
                <option value="low">Baja</option>
                <option value="medium">Media</option>
                <option value="high">Alta</option>
              </select>
            </div>
          </div>

          <!-- Asignados múltiples -->
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5">Asignar a</label>
            <div class="space-y-1 max-h-40 overflow-y-auto">
              <label 
                v-for="member in members" 
                :key="member.user_id"
                class="flex items-center gap-3 p-2 rounded-lg hover:bg-neutral-800 cursor-pointer"
              >
                <input 
                  type="checkbox" 
                  :value="member.user_id" 
                  v-model="taskForm.assignee_ids"
                  class="w-4 h-4 rounded border-neutral-600 text-cyan-500 focus:ring-cyan-500"
                >
                <div 
                  class="w-6 h-6 rounded-full flex items-center justify-center text-xs text-white flex-shrink-0"
                  :style="{ backgroundColor: getAvatarColor(member.user_id) }"
                >
                  {{ getInitials(member.full_name || member.email) }}
                </div>
                <div class="flex-1 min-w-0">
                  <div class="text-sm truncate">{{ member.full_name || member.email?.split('@')[0] }}</div>
                  <div class="text-xs text-neutral-500 truncate">{{ member.email }}</div>
                </div>
              </label>
            </div>
          </div>

          <div class="flex gap-3 pt-2">
            <button v-if="editingTask" type="button" @click="deleteTask" class="btn-secondary text-red-400 hover:text-red-300 text-sm">
              Eliminar
            </button>
            <div class="flex-1"></div>
            <button type="button" @click="closeTaskModal" class="btn-secondary text-sm">Cancelar</button>
            <button type="submit" class="btn-primary text-sm">{{ editingTask ? 'Guardar' : 'Crear' }}</button>
          </div>
        </form>
      </div>
    </div>

    <!-- Modal Agregar/Editar Columna -->
    <div v-if="showAddColumn" class="fixed inset-0 bg-black/60 flex items-end sm:items-center justify-center p-0 sm:p-4 z-50">
      <div class="card p-4 sm:p-6 w-full sm:max-w-sm rounded-t-2xl sm:rounded-xl">
        <div class="flex items-center justify-between mb-4">
          <h2 class="text-lg sm:text-xl font-bold">{{ editingColumn ? 'Editar columna' : 'Nueva columna' }}</h2>
          <button @click="closeColumnModal" class="p-2 -mr-2 text-neutral-400 hover:text-white">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
        <form @submit.prevent="saveColumn" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5">Nombre</label>
            <input v-model="columnForm.name" type="text" class="input" placeholder="Nombre de la columna" required>
          </div>
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5">Color</label>
            <div class="flex gap-2 flex-wrap">
              <button
                v-for="color in columnColors"
                :key="color"
                type="button"
                @click="columnForm.color = color"
                class="w-8 h-8 rounded-lg transition-transform hover:scale-110 active:scale-95"
                :class="{ 'ring-2 ring-white': columnForm.color === color }"
                :style="{ backgroundColor: color }"
              />
            </div>
          </div>
          <div class="flex gap-3 pt-2">
            <button v-if="editingColumn" type="button" @click="deleteColumn" class="btn-secondary text-red-400 hover:text-red-300 text-sm">
              Eliminar
            </button>
            <div class="flex-1"></div>
            <button type="button" @click="closeColumnModal" class="btn-secondary text-sm">Cancelar</button>
            <button type="submit" class="btn-primary text-sm">{{ editingColumn ? 'Guardar' : 'Crear' }}</button>
          </div>
        </form>
      </div>
    </div>

    <!-- Modal Invitar -->
    <div v-if="showInvite" class="fixed inset-0 bg-black/60 flex items-end sm:items-center justify-center p-0 sm:p-4 z-50">
      <div class="card p-4 sm:p-6 w-full sm:max-w-md rounded-t-2xl sm:rounded-xl">
        <div class="flex items-center justify-between mb-4">
          <h2 class="text-lg sm:text-xl font-bold">Invitar al workspace</h2>
          <button @click="showInvite = false" class="p-2 -mr-2 text-neutral-400 hover:text-white">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
        <form @submit.prevent="inviteMember" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5">Email</label>
            <input v-model="inviteEmail" type="email" class="input" placeholder="email@ejemplo.com" required>
          </div>
          <p class="text-sm text-neutral-500">
            El usuario debe estar registrado en Flowboard para poder ser invitado.
          </p>
          <div v-if="inviteError" class="text-red-400 text-sm">{{ inviteError }}</div>
          <div v-if="inviteSuccess" class="text-green-400 text-sm">{{ inviteSuccess }}</div>
          <div class="flex gap-3 pt-2">
            <button type="button" @click="showInvite = false" class="btn-secondary flex-1 text-sm">Cancelar</button>
            <button type="submit" class="btn-primary flex-1 text-sm">Invitar</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import draggable from 'vuedraggable'

definePageMeta({ middleware: 'auth' })

const route = useRoute()
const supabase = useSupabaseClient()
const user = useSupabaseUser()

const projectId = route.params.id as string
const project = ref<any>(null)
const tasks = ref<any[]>([])
const statuses = ref<any[]>([])
const members = ref<any[]>([])
const filterByUser = ref<string | null>(null)
const sidebarOpen = ref(false)

// Task Modal
const showTaskModal = ref(false)
const editingTask = ref<any>(null)
const taskForm = ref({
  title: '',
  description: '',
  status_id: '',
  priority: 'medium',
  assignee_ids: [] as string[]
})

// Column Modal
const showAddColumn = ref(false)
const editingColumn = ref<any>(null)
const columnForm = ref({ name: '', color: '#78716c' })
const columnColors = ['#78716c', '#ef4444', '#f59e0b', '#10b981', '#06b6d4', '#8b5cf6', '#ec4899']
const defaultColumns = ['Por hacer', 'En progreso', 'En revisión', 'Completado']

// Invite Modal
const showInvite = ref(false)
const inviteEmail = ref('')
const inviteError = ref('')
const inviteSuccess = ref('')

// Computed
const filteredTasks = computed(() => {
  if (!filterByUser.value) return tasks.value
  return tasks.value.filter(t => 
    t.assignees?.some((a: any) => a.user_id === filterByUser.value)
  )
})

const getTasksByStatus = (statusId: string) => {
  return filteredTasks.value.filter(t => t.status_id === statusId)
}

const isDefaultColumn = (name: string) => defaultColumns.includes(name)

// Helpers
const getAvatarColor = (userId: string) => {
  const colors = ['#ef4444', '#f59e0b', '#10b981', '#06b6d4', '#8b5cf6', '#ec4899', '#6366f1']
  const index = userId.charCodeAt(0) % colors.length
  return colors[index]
}

const getInitials = (name: string) => {
  if (!name) return '?'
  return name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)
}

const getMemberName = (userId: string) => {
  const member = members.value.find(m => m.user_id === userId)
  return member?.full_name || member?.email?.split('@')[0] || 'Usuario'
}

const priorityClass = (priority: string) => ({
  'bg-red-500/20 text-red-400': priority === 'high',
  'bg-amber-500/20 text-amber-400': priority === 'medium',
  'bg-neutral-700 text-neutral-400': priority === 'low'
})

const priorityLabel = (priority: string) => {
  const labels: Record<string, string> = { high: 'Alta', medium: 'Media', low: 'Baja' }
  return labels[priority] || priority
}

const getUserId = (u: any): string | null => {
  if (!u) return null
  return u.id || u.sub || null
}

// Drag & Drop
const onDragChange = async (event: any, newStatusId: string) => {
  if (event.added) {
    const task = event.added.element
    task.status_id = newStatusId
    
    await supabase
      .from('tasks')
      .update({ status_id: newStatusId, updated_at: new Date().toISOString() })
      .eq('id', task.id)
  }
}

// Task CRUD
const openNewTask = () => {
  editingTask.value = null
  taskForm.value = { 
    title: '', 
    description: '', 
    status_id: statuses.value[0]?.id || '', 
    priority: 'medium', 
    assignee_ids: []
  }
  showTaskModal.value = true
}

const addTaskToColumn = (statusId: string) => {
  editingTask.value = null
  taskForm.value = { 
    title: '', 
    description: '', 
    status_id: statusId, 
    priority: 'medium', 
    assignee_ids: []
  }
  showTaskModal.value = true
}

const openEditTask = (task: any) => {
  editingTask.value = task
  taskForm.value = {
    title: task.title,
    description: task.description || '',
    status_id: task.status_id,
    priority: task.priority,
    assignee_ids: task.assignees?.map((a: any) => a.user_id) || []
  }
  showTaskModal.value = true
}

const closeTaskModal = () => {
  showTaskModal.value = false
  editingTask.value = null
}

const saveTask = async () => {
  if (!taskForm.value.title.trim()) return

  const userId = getUserId(user.value)

  if (editingTask.value) {
    const { error } = await supabase
      .from('tasks')
      .update({
        title: taskForm.value.title,
        description: taskForm.value.description,
        status_id: taskForm.value.status_id,
        priority: taskForm.value.priority,
        updated_at: new Date().toISOString()
      })
      .eq('id', editingTask.value.id)

    if (!error) {
      await supabase.from('task_assignees').delete().eq('task_id', editingTask.value.id)
      if (taskForm.value.assignee_ids.length > 0) {
        await supabase.from('task_assignees').insert(
          taskForm.value.assignee_ids.map(uid => ({
            task_id: editingTask.value.id,
            user_id: uid
          }))
        )
      }
      
      Object.assign(editingTask.value, {
        ...taskForm.value,
        assignees: members.value.filter(m => taskForm.value.assignee_ids.includes(m.user_id))
      })
    }
  } else {
    const { data, error } = await supabase
      .from('tasks')
      .insert({
        project_id: projectId,
        title: taskForm.value.title,
        description: taskForm.value.description,
        status_id: taskForm.value.status_id,
        priority: taskForm.value.priority,
        created_by: userId,
        position: tasks.value.length
      })
      .select()
      .single()

    if (!error && data) {
      if (taskForm.value.assignee_ids.length > 0) {
        await supabase.from('task_assignees').insert(
          taskForm.value.assignee_ids.map(uid => ({
            task_id: data.id,
            user_id: uid
          }))
        )
      }
      
      data.assignees = members.value.filter(m => taskForm.value.assignee_ids.includes(m.user_id))
      tasks.value.push(data)
    }
  }

  closeTaskModal()
}

const deleteTask = async () => {
  if (!editingTask.value) return

  await supabase.from('tasks').delete().eq('id', editingTask.value.id)
  tasks.value = tasks.value.filter(t => t.id !== editingTask.value.id)
  closeTaskModal()
}

// Column CRUD
const editColumn = (column: any) => {
  editingColumn.value = column
  columnForm.value = { name: column.name, color: column.color }
  showAddColumn.value = true
}

const closeColumnModal = () => {
  showAddColumn.value = false
  editingColumn.value = null
  columnForm.value = { name: '', color: '#78716c' }
}

const saveColumn = async () => {
  if (!columnForm.value.name.trim()) return

  if (editingColumn.value) {
    const { error } = await supabase
      .from('task_statuses')
      .update({ name: columnForm.value.name, color: columnForm.value.color })
      .eq('id', editingColumn.value.id)

    if (!error) {
      Object.assign(editingColumn.value, columnForm.value)
    }
  } else {
    const { data, error } = await supabase
      .from('task_statuses')
      .insert({
        project_id: projectId,
        name: columnForm.value.name,
        color: columnForm.value.color,
        position: statuses.value.length
      })
      .select()
      .single()

    if (!error && data) {
      statuses.value.push(data)
    }
  }

  closeColumnModal()
}

const deleteColumn = async () => {
  if (!editingColumn.value) return
  
  const tasksInColumn = tasks.value.filter(t => t.status_id === editingColumn.value.id)
  if (tasksInColumn.length > 0) {
    alert('No puedes eliminar una columna con tareas. Mueve las tareas primero.')
    return
  }

  await supabase.from('task_statuses').delete().eq('id', editingColumn.value.id)
  statuses.value = statuses.value.filter(s => s.id !== editingColumn.value.id)
  closeColumnModal()
}

// Invite
const inviteMember = async () => {
  inviteError.value = ''
  inviteSuccess.value = ''

  const { data: profile } = await supabase
    .from('profiles')
    .select('id, email, full_name')
    .eq('email', inviteEmail.value)
    .single()

  if (!profile) {
    inviteError.value = 'Usuario no encontrado. Debe estar registrado en Flowboard.'
    return
  }

  const existing = members.value.find(m => m.user_id === profile.id)
  if (existing) {
    inviteError.value = 'Este usuario ya es miembro del workspace.'
    return
  }

  const { error } = await supabase
    .from('workspace_members')
    .insert({
      workspace_id: project.value.workspace_id,
      user_id: profile.id,
      role: 'member'
    })

  if (error) {
    inviteError.value = 'Error al invitar: ' + error.message
    return
  }

  members.value.push({ user_id: profile.id, email: profile.email, full_name: profile.full_name, role: 'member' })
  inviteSuccess.value = '¡Usuario invitado exitosamente!'
  inviteEmail.value = ''
  
  setTimeout(() => {
    showInvite.value = false
    inviteSuccess.value = ''
  }, 2000)
}

// Load data
const loadProject = async () => {
  const { data } = await supabase
    .from('projects')
    .select('*')
    .eq('id', projectId)
    .single()

  if (data) {
    project.value = data
    loadMembers(data.workspace_id)
  }
}

const loadStatuses = async () => {
  const { data } = await supabase
    .from('task_statuses')
    .select('*')
    .eq('project_id', projectId)
    .order('position', { ascending: true })

  if (data) {
    statuses.value = data
  }
}

const loadTasks = async () => {
  const { data: tasksData } = await supabase
    .from('tasks')
    .select('*')
    .eq('project_id', projectId)
    .order('position', { ascending: true })

  if (tasksData) {
    const { data: assigneesData } = await supabase
      .from('task_assignees')
      .select('task_id, user_id, profiles(email, full_name)')
      .in('task_id', tasksData.map(t => t.id))

    tasks.value = tasksData.map(task => ({
      ...task,
      assignees: assigneesData
        ?.filter(a => a.task_id === task.id)
        .map(a => ({
          user_id: a.user_id,
          email: (a.profiles as any)?.email,
          full_name: (a.profiles as any)?.full_name
        })) || []
    }))
  }
}

const loadMembers = async (workspaceId: string) => {
  const { data } = await supabase
    .from('workspace_members')
    .select('user_id, role, profiles(email, full_name)')
    .eq('workspace_id', workspaceId)

  if (data) {
    members.value = data.map((m: any) => ({
      user_id: m.user_id,
      role: m.role,
      email: m.profiles?.email,
      full_name: m.profiles?.full_name
    }))
  }
}

onMounted(async () => {
  await loadProject()
  await loadStatuses()
  await loadTasks()
})
</script>