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
        <button @click="isMobileMenuOpen = !isMobileMenuOpen" :aria-label="t('menu')" class="p-2 text-neutral-400">
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
        <label class="block text-xs font-medium text-neutral-500 uppercase mb-2 px-1">{{ t('workspace') }}</label>
        <button @click="showWorkspaceDropdown = !showWorkspaceDropdown" class="w-full flex items-center justify-between p-3 bg-neutral-900 rounded-lg hover:bg-neutral-800 transition-colors">
          <div class="flex items-center gap-3 min-w-0">
            <div class="w-7 h-7 rounded-lg flex items-center justify-center text-white font-bold text-xs" :style="{ backgroundColor: currentWorkspace?.color || '#06b6d4' }">
              {{ currentWorkspace?.name?.charAt(0) || 'W' }}
            </div>
            <span class="font-medium truncate text-sm">{{ currentWorkspace?.name || t('selectWorkspace') }}</span>
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
              <span class="text-sm">{{ t('newWorkspace') }}</span>
            </button>
          </div>
        </div>
      </div>

      <nav class="flex-1 space-y-1 overflow-y-auto">
        <NuxtLink to="/dashboard" class="sidebar-item sidebar-item-active" @click="isMobileMenuOpen = false">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
          </svg>
          {{ t('dashboard') }}
        </NuxtLink>

        <div class="pt-4 pb-2">
          <span class="px-3 text-xs font-medium text-neutral-500 uppercase">{{ t('projects') }}</span>
        </div>

        <NuxtLink 
          v-for="project in activeProjects"
          :key="project.id"
          :to="`/project/${project.id}`"
          class="sidebar-item"
          @click="isMobileMenuOpen = false"
        >
          <div class="w-2 h-2 rounded-full shrink-0" :style="{ backgroundColor: project.color || '#06b6d4' }" />
          <span class="truncate">{{ project.name }}</span>
        </NuxtLink>

        <button v-if="currentWorkspace" @click="openNewProject" class="sidebar-item w-full text-left text-cyan-400">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 4v16m8-8H4" />
          </svg>
          {{ t('newProject') }}
        </button>
      </nav>

      <div class="pt-4 border-t border-neutral-800 space-y-1">
        <AppLanguagePicker class="m-2" />
        <button v-if="currentWorkspace" @click="showWorkspaceSettings = true" class="sidebar-item w-full text-left text-neutral-400 hover:text-white">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
          </svg>
          {{ t('settings') }}
        </button>
        <button @click="handleLogout" class="sidebar-item w-full text-left text-red-400 hover:text-red-300">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
          </svg>
          {{ t('signOut') }}
        </button>
      </div>
    </aside>

    <!-- Overlay móvil -->
    <div v-if="isMobileMenuOpen" @click="isMobileMenuOpen = false" class="fixed inset-0 bg-black/50 z-40 md:hidden" />

    <!-- Main Content -->
    <main class="flex-1 p-4 md:p-8 overflow-y-auto">
      <div class="flex items-center justify-between mb-8">
        <div>
          <h1 class="text-xl md:text-2xl font-bold">{{ currentWorkspace?.name || t('dashboard') }}</h1>
          <p class="text-neutral-400 text-sm">{{ countProjects(activeProjects.length) }}</p>
        </div>
        <div class="hidden md:block">
          <AppNotificationBell />
        </div>
      </div>

      <!-- Stats -->
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 mb-8">
        <div class="card p-4 md:p-6">
          <p class="text-2xl md:text-3xl font-bold">{{ activeProjects.length }}</p>
          <p class="text-neutral-400 text-sm">{{ t('activeProjects') }}</p>
        </div>
        <div class="card p-4 md:p-6">
          <p class="text-2xl md:text-3xl font-bold">{{ taskStats.pending }}</p>
          <p class="text-neutral-400 text-sm">{{ t('pendingTasks') }}</p>
        </div>
        <div class="card p-4 md:p-6 sm:col-span-2 lg:col-span-1">
          <p class="text-2xl md:text-3xl font-bold">{{ taskStats.completed }}</p>
          <p class="text-neutral-400 text-sm">{{ t('completedTasks') }}</p>
        </div>
      </div>

      <!-- Projects -->
      <div class="mb-4 flex flex-wrap items-center justify-between gap-3">
        <h2 class="text-lg font-semibold">{{ t('projects') }}</h2>
        <div v-if="currentWorkspace && (archivedProjects.length || showArchivedProjects)" class="flex flex-wrap gap-2">
          <button type="button" :class="showArchivedProjects ? 'btn-secondary' : 'btn-primary'" :aria-pressed="!showArchivedProjects" @click="showArchivedProjects = false">
            {{ t('activeProjects') }}
          </button>
          <button type="button" :class="showArchivedProjects ? 'btn-primary' : 'btn-secondary'" :aria-pressed="showArchivedProjects" @click="showArchivedProjects = true">
            {{ t('archivedProjects') }} ({{ archivedProjects.length }})
          </button>
        </div>
      </div>
      
      <div v-if="loading" class="text-neutral-400 italic">{{ t('loading') }}</div>
      
      <div v-else-if="workspaceLoadError" class="card p-8 text-center" role="alert">
        {{ t('workspaceLoadError') }}
      </div>

      <div v-else-if="!currentWorkspace" class="card p-8 text-center">
        <p class="text-neutral-400 mb-4">{{ t('noWorkspace') }}</p>
        <button @click="openNewWorkspace" class="btn-primary w-full sm:w-auto">{{ t('createWorkspace') }}</button>
      </div>

      <div v-else-if="visibleProjects.length === 0" class="card p-8 text-center">
        <p class="text-neutral-400" :class="{ 'mb-4': !showArchivedProjects }">
          {{ t(showArchivedProjects ? 'noArchivedProjects' : 'noProjects') }}
        </p>
        <button v-if="!showArchivedProjects" @click="openNewProject" class="btn-primary w-full sm:w-auto">
          {{ t('createFirstProject') }}
        </button>
      </div>

      <div v-else class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        <article v-for="project in visibleProjects" :key="project.id" class="card flex flex-wrap items-center gap-3 p-4 md:p-6">
          <NuxtLink :to="`/project/${project.id}`" class="flex min-w-0 flex-1 items-center gap-3 hover:text-cyan-300">
            <div class="w-10 h-10 rounded-lg shrink-0 flex items-center justify-center text-white font-bold" :style="{ backgroundColor: project.color || '#06b6d4' }">
              {{ project.name.charAt(0) }}
            </div>
            <div class="flex-1 min-w-0">
              <h3 class="font-semibold truncate text-sm md:text-base">{{ project.name }}</h3>
              <p class="text-xs text-neutral-500">{{ formatDate(project.created_at) }}</p>
            </div>
          </NuxtLink>
          <button v-if="currentWorkspace.role === 'owner'" type="button" class="btn-ghost text-sm" @click="openProjectSettings(project)">
            {{ t('editProject') }}
          </button>
        </article>
      </div>
    </main>

    <!-- Modal Nuevo Workspace -->
    <div v-if="showNewWorkspace" class="fixed inset-0 bg-black/60 flex items-end sm:items-center justify-center p-0 sm:p-4 z-[60]">
      <div class="card p-6 w-full max-w-md rounded-t-2xl sm:rounded-xl">
        <div class="flex items-center justify-between mb-4">
          <h2 class="text-xl font-bold">{{ t('newWorkspace') }}</h2>
          <button @click="showNewWorkspace = false" class="p-2 -mr-2 text-neutral-400 hover:text-white">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
        <form @submit.prevent="createWorkspace" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5">{{ t('name') }}</label>
            <input v-model="workspaceForm.name" type="text" class="input" :placeholder="t('workspacePlaceholder')" required>
          </div>
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5">{{ t('color') }}</label>
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
            <button type="button" @click="showNewWorkspace = false" class="btn-secondary w-full">{{ t('cancel') }}</button>
            <button type="submit" class="btn-primary w-full">{{ t('createWorkspace') }}</button>
          </div>
        </form>
      </div>
    </div>

    <!-- Modal Nuevo Proyecto -->
    <div v-if="showNewProject" class="fixed inset-0 bg-black/60 flex items-end sm:items-center justify-center p-0 sm:p-4 z-[60]">
      <div class="card p-6 w-full max-w-md rounded-t-2xl sm:rounded-xl">
        <div class="flex items-center justify-between mb-4">
          <h2 class="text-xl font-bold">{{ t(editingProject ? 'editProject' : 'newProject') }}</h2>
          <button @click="showNewProject = false" :disabled="creating" :aria-label="t('close')" class="p-2 -mr-2 text-neutral-400 hover:text-white">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
        <form @submit.prevent="submitProject" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5">{{ t('name') }}</label>
            <input v-model="projectForm.name" type="text" class="input" :placeholder="t('projectPlaceholder')" required>
          </div>
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5">{{ t('optionalDescription') }}</label>
            <textarea v-model="projectForm.description" class="input" rows="2" :placeholder="t('descriptionPlaceholder')"></textarea>
          </div>
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5">{{ t('color') }}</label>
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
          <div v-if="createError" class="text-red-400 text-sm" role="alert">{{ t(createError) }}</div>
          <div class="flex flex-col-reverse sm:flex-row gap-3 pt-2">
            <button type="button" @click="showNewProject = false" :disabled="creating" class="btn-secondary w-full">{{ t('cancel') }}</button>
            <button type="submit" class="btn-primary w-full" :disabled="creating">
              {{ t(creating ? (editingProject ? 'saving' : 'creating') : (editingProject ? 'save' : 'create')) }}
            </button>
          </div>
        </form>
        <button v-if="editingProject" type="button" class="btn-ghost mt-3 text-sm" :disabled="creating" @click="toggleProjectArchive">
          {{ t(editingProject.archived_at ? 'restoreProject' : 'archiveProject') }}
        </button>
      </div>
    </div>

    <!-- Modal Configuración Workspace -->
    <div v-if="showWorkspaceSettings" class="fixed inset-0 bg-black/60 flex items-end sm:items-center justify-center p-0 sm:p-4 z-[60]">
      <div class="card p-6 w-full max-w-md rounded-t-2xl sm:rounded-xl max-h-[90vh] overflow-y-auto">
        <div class="flex items-center justify-between mb-4">
          <h2 class="text-xl font-bold">{{ t('settings') }}</h2>
          <button @click="showWorkspaceSettings = false" class="p-2 -mr-2 text-neutral-400 hover:text-white">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
        <form @submit.prevent="updateWorkspace" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5">{{ t('workspaceName') }}</label>
            <input v-model="workspaceSettingsForm.name" :disabled="currentWorkspace?.role !== 'owner'" type="text" class="input" required>
          </div>
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5">{{ t('color') }}</label>
            <div class="flex flex-wrap gap-3">
              <button
                v-for="color in colors"
                :key="color"
                type="button"
                @click="workspaceSettingsForm.color = color"
                :disabled="currentWorkspace?.role !== 'owner'"
                class="w-10 h-10 sm:w-8 sm:h-8 rounded-lg transition-transform hover:scale-110"
                :class="{ 'ring-2 ring-white ring-offset-2 ring-offset-neutral-900': workspaceSettingsForm.color === color }"
                :style="{ backgroundColor: color }"
              />
            </div>
          </div>
          
          <!-- Miembros -->
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-2">{{ t('members', { count: workspaceMembers.length }) }}</label>
            <div class="space-y-2 max-h-40 overflow-y-auto">
              <div v-for="member in workspaceMembers" :key="member.user_id" class="flex items-center justify-between p-2 bg-neutral-800 rounded-lg">
                <div class="flex items-center gap-2 min-w-0">
                  <div class="w-7 h-7 rounded-full bg-cyan-500 flex items-center justify-center text-xs text-white flex-shrink-0">
                    {{ member.full_name?.charAt(0) || member.email?.charAt(0) || '?' }}
                  </div>
                  <span class="text-sm truncate">{{ member.full_name || member.email }}</span>
                </div>
                <div class="ml-2 flex shrink-0 items-center gap-2">
                  <span class="text-xs text-neutral-400">{{ t(member.role === 'owner' ? 'owner' : 'member') }}</span>
                  <button
                    v-if="currentWorkspace?.role === 'owner' && member.role === 'member'"
                    type="button"
                    class="text-xs text-red-400 hover:text-red-300"
                    :disabled="removingMember"
                    @click="removeMember(member)"
                  >{{ t('removeMember') }}</button>
                </div>
              </div>
            </div>
            <p v-if="memberRemoveError" role="alert" class="mt-2 text-sm text-red-400">{{ t('memberRemoveError') }}</p>
          </div>

          <div class="flex flex-col-reverse sm:flex-row gap-3 pt-2">
            <button 
              v-if="currentWorkspace?.role === 'owner'"
              type="button" 
              @click="deleteWorkspace" 
              class="btn-secondary text-red-400 hover:text-red-300"
            >
              {{ t('deleteWorkspace') }}
            </button>
            <div class="flex-1"></div>
            <button type="button" @click="showWorkspaceSettings = false" class="btn-secondary">{{ t('cancel') }}</button>
            <button v-if="currentWorkspace?.role === 'owner'" type="submit" class="btn-primary">{{ t('save') }}</button>
          </div>
        </form>
        <section v-if="currentWorkspace?.role === 'owner'" class="mt-5 space-y-3 border-t border-neutral-800 pt-4">
          <h3 class="font-medium">{{ t('workspaceInvitation') }}</h3>
          <AppWorkspaceInviteForm :key="currentWorkspace.id" :workspace-id="currentWorkspace.id" @member-added="loadWorkspaceMembers" />
        </section>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { MessageKey } from '~/utils/interfaceMessages'

interface BoardProject {
  id: string
  name: string
  description: string
  color: string
  created_at: string
  archived_at: string | null
}

interface WorkspaceMember {
  user_id: string
  role: 'owner' | 'member'
  email?: string
  full_name?: string
}

const { t, locale, countProjects } = useInterfaceLanguage()
definePageMeta({ middleware: 'auth' })

const supabase = useSupabaseClient()
const user = useSupabaseUser()
const session = useSupabaseSession()

// UI State
const isMobileMenuOpen = ref(false)
const showWorkspaceDropdown = ref(false)
const showNewWorkspace = ref(false)
const showNewProject = ref(false)
const showWorkspaceSettings = ref(false)
const showArchivedProjects = ref(false)
const editingProject = ref<BoardProject | null>(null)
const removingMember = ref(false)
const memberRemoveError = ref(false)

// Data
const loading = ref(true)
const creating = ref(false)
const createError = ref<MessageKey | null>(null)
const workspaceLoadError = ref(false)
const workspaces = ref<any[]>([])
const currentWorkspace = ref<any>(null)
const workspaceMembers = ref<WorkspaceMember[]>([])
const projects = ref<BoardProject[]>([])
const activeProjects = computed(() => projects.value.filter(project => !project.archived_at))
const archivedProjects = computed(() => projects.value.filter(project => project.archived_at))
const visibleProjects = computed(() => showArchivedProjects.value ? archivedProjects.value : activeProjects.value)
const taskStats = ref({ pending: 0, completed: 0 })

// Forms
const colors = ['#06b6d4', '#8b5cf6', '#f59e0b', '#10b981', '#ef4444', '#ec4899', '#6366f1']
const workspaceForm = ref({ name: '', color: '#06b6d4' })
const projectForm = ref({ name: '', description: '', color: '#06b6d4' })
const workspaceSettingsForm = ref({ name: '', color: '#06b6d4' })

// Helpers
const getUserId = (u: any): string | null => u?.id || u?.sub || null
const accountId = computed(() => session.value?.user.id ?? getUserId(user.value))

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString(locale.value, { day: 'numeric', month: 'short' })
}


// Load workspaces
const loadWorkspaces = async (userId: string) => {
  workspaceLoadError.value = false
  const { data, error } = await supabase
    .from('workspace_members')
    .select('workspace_id, role, workspaces(id, name, color, owner_id)')
    .eq('user_id', userId)
  if (accountId.value !== userId) return
  if (error) {
    console.error('Could not load workspaces:', error)
    workspaceLoadError.value = true
    return
  }

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
  }
}

// Switch workspace
const switchWorkspace = async (workspace: any) => {
  currentWorkspace.value = workspace ?? null
  projects.value = []
  showArchivedProjects.value = false
  workspaceMembers.value = []
  taskStats.value = { pending: 0, completed: 0 }
  if (workspace) localStorage.setItem('lastWorkspaceId', workspace.id)
  else localStorage.removeItem('lastWorkspaceId')
  showWorkspaceDropdown.value = false
  isMobileMenuOpen.value = false
  await Promise.all([loadProjects(), loadWorkspaceMembers()])
  if (currentWorkspace.value?.id === workspace?.id) await loadTaskStats()
}

// Load projects for current workspace
const loadProjects = async () => {
  const workspaceId = currentWorkspace.value?.id
  if (!workspaceId) {
    loading.value = false
    return
  }
  
  loading.value = true
  
  const { data } = await supabase
    .from('projects')
    .select('*')
    .eq('workspace_id', workspaceId)
    .order('created_at', { ascending: false })

  if (currentWorkspace.value?.id !== workspaceId) return
  if (data) {
    projects.value = data
  }
  
  loading.value = false
}

// Load workspace members
const loadWorkspaceMembers = async () => {
  const workspaceId = currentWorkspace.value?.id
  if (!workspaceId) return

  const { data } = await supabase
    .from('workspace_members')
    .select('user_id, role, profiles(email, full_name)')
    .eq('workspace_id', workspaceId)

  if (data && currentWorkspace.value?.id === workspaceId) {
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
  const workspaceId = currentWorkspace.value?.id
  const projectIds = activeProjects.value.map(project => project.id)
  if (projectIds.length === 0) {
    taskStats.value = { pending: 0, completed: 0 }
    return
  }
  
  
  const { data: statuses } = await supabase
    .from('task_statuses')
    .select('id, name')
    .in('project_id', projectIds)
  
  const completedStatusIds = statuses
    ?.filter(s => isCompletedStatus(s.name))
    .map(s => s.id) || []
  
  const { data: tasks } = await supabase
    .from('tasks')
    .select('id, status_id')
    .in('project_id', projectIds)
  
  if (tasks && currentWorkspace.value?.id === workspaceId
    && activeProjects.value.map(project => project.id).join() === projectIds.join()) {
    taskStats.value = {
      completed: tasks.filter(t => completedStatusIds.includes(t.status_id)).length,
      pending: tasks.filter(t => !completedStatusIds.includes(t.status_id)).length
    }
  }
}

// Create workspace
const openNewWorkspace = () => {
  showWorkspaceDropdown.value = false
  isMobileMenuOpen.value = false
  workspaceForm.value = { name: '', color: '#06b6d4' }
  showNewWorkspace.value = true
}

const createWorkspace = async () => {
  const userId = accountId.value
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
    const newWs = { ...workspace, role: 'owner' }
    workspaces.value.push(newWs)
    switchWorkspace(newWs)
    showNewWorkspace.value = false
  } else if (error) {
    console.error('Could not create workspace:', error)
    alert(t('workspaceCreateError'))
  }
}

// Update workspace
const updateWorkspace = async () => {
  if (currentWorkspace.value?.role !== 'owner') return

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
  if (!currentWorkspace.value) return
  
  if (!confirm(t('deleteWorkspaceConfirm', { name: currentWorkspace.value.name }))) return

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

const openNewProject = () => {
  if (!currentWorkspace.value) return
  createError.value = null
  editingProject.value = null
  projectForm.value = { name: '', description: '', color: '#06b6d4' }
  isMobileMenuOpen.value = false
  showNewProject.value = true
}

function openProjectSettings(project: BoardProject) {
  if (currentWorkspace.value?.role !== 'owner') return
  createError.value = null
  editingProject.value = project
  projectForm.value = { name: project.name, description: project.description, color: project.color }
  showNewProject.value = true
}

async function updateProject(changes: Partial<Pick<BoardProject, 'name' | 'description' | 'color' | 'archived_at'>>) {
  const project = editingProject.value
  const workspaceId = currentWorkspace.value?.id
  if (!project || !workspaceId || currentWorkspace.value?.role !== 'owner' || creating.value) return

  creating.value = true
  createError.value = null
  try {
    const { data, error } = await supabase.from('projects').update(changes)
      .eq('id', project.id).eq('workspace_id', workspaceId).select().single()
    if (error || !data) {
      createError.value = 'projectUpdateError'
      return
    }
    if (currentWorkspace.value?.id === workspaceId) {
      projects.value = projects.value.map(row => row.id === project.id ? data : row)
      void loadTaskStats()
    }
    showNewProject.value = false
  } catch {
    createError.value = 'projectUpdateError'
  } finally {
    creating.value = false
  }
}

async function submitProject() {
  if (!editingProject.value) return createProject()
  const name = projectForm.value.name.trim()
  if (!name) {
    createError.value = 'projectNameRequired'
    return
  }
  await updateProject({ ...projectForm.value, name })
}

async function toggleProjectArchive() {
  const project = editingProject.value
  if (!project) return
  if (!project.archived_at && !confirm(t('archiveProjectConfirm', { name: project.name }))) return
  await updateProject({ archived_at: project.archived_at ? null : new Date().toISOString() })
}

async function removeMember(member: WorkspaceMember) {
  const workspace = currentWorkspace.value
  if (workspace?.role !== 'owner' || member.role !== 'member' || removingMember.value) return
  const name = member.full_name || member.email || t('member')
  if (!confirm(t('removeMemberConfirm', { name }))) return
  removingMember.value = true
  memberRemoveError.value = false
  try {
    const { error } = await supabase.rpc('remove_workspace_member', {
      workspace: workspace.id,
      member_id: member.user_id,
    })
    if (error) {
      memberRemoveError.value = true
      return
    }
    if (currentWorkspace.value?.id === workspace.id) {
      workspaceMembers.value = workspaceMembers.value.filter(row => row.user_id !== member.user_id)
    }
  } catch {
    memberRemoveError.value = true
  } finally {
    removingMember.value = false
  }
}

const createProject = async () => {
  if (creating.value) return

  const workspaceId = currentWorkspace.value?.id
  const name = projectForm.value.name.trim()
  if (!workspaceId) {
    createError.value = 'projectWorkspaceRequired'
    return
  }
  if (!name) {
    createError.value = 'projectNameRequired'
    return
  }

  creating.value = true
  createError.value = null
  try {
    const { data: { session: activeSession } } = await supabase.auth.getSession()
    if (!activeSession) {
      createError.value = 'projectSessionRequired'
      return
    }

    const { data: project, error } = await supabase
      .from('projects')
      .insert({
        name,
        description: projectForm.value.description,
        color: projectForm.value.color,
        workspace_id: workspaceId,
        created_by: activeSession.user.id
      })
      .select()
      .single()

    if (error || !project) {
      console.error('Could not create project:', error)
      createError.value = error?.code === '42501' ? 'projectAccessError' : 'projectCreateError'
      return
    }

    if (currentWorkspace.value?.id === workspaceId) projects.value.unshift(project)
    showNewProject.value = false
    projectForm.value = { name: '', description: '', color: '#06b6d4' }
    await navigateTo(`/project/${project.id}`)
  } catch (error) {
    console.error('Could not create project:', error)
    createError.value = 'projectCreateError'
  } finally {
    creating.value = false
  }
}

// Watch for settings modal
watch(showWorkspaceSettings, (val) => {
  if (val && currentWorkspace.value) {
    memberRemoveError.value = false
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
watch(accountId, async (userId) => {
  if (userId) {
    await loadWorkspaces(userId)
    if (accountId.value !== userId) return
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
