<script setup lang="ts">
interface Label {
  id: string
  name: string
  color: string
}

interface Props {
  projectPrefix: string
  taskNumber: number
  taskTitle: string
  labels?: Label[]
}

const props = defineProps<Props>()

const copied = ref<'branch' | 'commit' | 'key' | null>(null)

// Generar el key del ticket (ej: SEUT-7)
const ticketKey = computed(() => `${props.projectPrefix}-${props.taskNumber}`)

// Convertir título a slug para nombre de rama
const slugify = (text: string) => {
  return text
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '') // Quitar acentos
    .replace(/[^a-z0-9]+/g, '-')     // Reemplazar espacios y especiales con -
    .replace(/^-+|-+$/g, '')          // Quitar - al inicio/final
    .substring(0, 50)                 // Limitar longitud
}

// Formatear etiquetas para el commit (ej: "bug, fix")
const labelsText = computed(() => {
  if (!props.labels || props.labels.length === 0) return ''
  return props.labels.map(l => l.name).join(', ')
})

// Comandos de Git
const branchName = computed(() => [slugify(ticketKey.value), slugify(props.taskTitle)].filter(Boolean).join('-'))
const gitCheckoutCommand = computed(() => `git checkout -b ${branchName.value}`)

const gitCommitCommand = computed(() => {
  const base = `${ticketKey.value} ${props.taskTitle}`
  const message = labelsText.value ? `${labelsText.value}: ${base}` : base
  const quoted = message.replace(/\r?\n|\r/g, ' ').replace(/'/g, "'\"'\"'")
  return `git commit -m '${quoted}'`
})

// Copiar al portapapeles
const copyToClipboard = async (text: string, type: 'branch' | 'commit' | 'key') => {
  try {
    await navigator.clipboard.writeText(text)
    copied.value = type
    setTimeout(() => {
      copied.value = null
    }, 2000)
  } catch (err) {
    console.error('Error al copiar:', err)
  }
}

// Estado de los dropdowns
const showBranchDropdown = ref(false)
const showCommitDropdown = ref(false)

const toggleBranch = () => {
  showBranchDropdown.value = !showBranchDropdown.value
  showCommitDropdown.value = false
}

const toggleCommit = () => {
  showCommitDropdown.value = !showCommitDropdown.value
  showBranchDropdown.value = false
}
</script>

<template>
  <div class="border-t border-neutral-800 pt-4 mt-4">
    <div class="flex items-center gap-2 mb-3">
      <svg class="w-4 h-4 text-neutral-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" />
      </svg>
      <span class="text-sm font-medium text-neutral-400">Desarrollo</span>
      <span class="text-xs bg-neutral-800 text-neutral-300 px-2 py-0.5 rounded font-mono">
        {{ ticketKey }}
      </span>
    </div>

    <div class="space-y-2">
      <!-- Crear rama -->
      <div class="relative">
        <button
          @click="toggleBranch"
          class="w-full flex items-center justify-between gap-2 px-3 py-2 text-sm text-left rounded-lg transition-colors"
          :class="showBranchDropdown ? 'bg-cyan-500/10 text-cyan-400 border border-cyan-500/30' : 'text-neutral-300 hover:bg-neutral-800 border border-transparent'"
        >
          <div class="flex items-center gap-2">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
            </svg>
            <span>Crear rama</span>
          </div>
          <svg 
            class="w-4 h-4 transition-transform" 
            :class="{ 'rotate-180': showBranchDropdown }"
            fill="none" 
            stroke="currentColor" 
            viewBox="0 0 24 24"
          >
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M19 9l-7 7-7-7" />
          </svg>
        </button>

        <div v-if="showBranchDropdown" class="mt-2 p-3 bg-neutral-800/50 rounded-lg border border-neutral-700">
          <p class="text-xs text-neutral-400 mb-2 uppercase tracking-wide">Git checkout de nueva rama</p>
          <div class="flex items-center gap-2">
            <code class="flex-1 text-xs bg-neutral-900 text-neutral-200 p-2 rounded font-mono overflow-x-auto">
              {{ gitCheckoutCommand }}
            </code>
            <button
              @click="copyToClipboard(gitCheckoutCommand, 'branch')"
              class="p-2 text-neutral-400 hover:text-white hover:bg-neutral-700 rounded transition-colors flex-shrink-0"
              :title="copied === 'branch' ? '¡Copiado!' : 'Copiar'"
            >
              <svg v-if="copied !== 'branch'" class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
              </svg>
              <svg v-else class="w-4 h-4 text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
              </svg>
            </button>
          </div>
        </div>
      </div>

      <!-- Crear commit -->
      <div class="relative">
        <button
          @click="toggleCommit"
          class="w-full flex items-center justify-between gap-2 px-3 py-2 text-sm text-left rounded-lg transition-colors"
          :class="showCommitDropdown ? 'bg-cyan-500/10 text-cyan-400 border border-cyan-500/30' : 'text-neutral-300 hover:bg-neutral-800 border border-transparent'"
        >
          <div class="flex items-center gap-2">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <span>Crear confirmación</span>
          </div>
          <svg 
            class="w-4 h-4 transition-transform" 
            :class="{ 'rotate-180': showCommitDropdown }"
            fill="none" 
            stroke="currentColor" 
            viewBox="0 0 24 24"
          >
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M19 9l-7 7-7-7" />
          </svg>
        </button>

        <div v-if="showCommitDropdown" class="mt-2 p-3 bg-neutral-800/50 rounded-lg border border-neutral-700 space-y-3">
          <div>
            <p class="text-xs text-neutral-400 mb-2 uppercase tracking-wide">Copiar clave</p>
            <div class="flex items-center gap-2">
              <code class="flex-1 text-xs bg-neutral-900 text-neutral-200 p-2 rounded font-mono">
                {{ ticketKey }}
              </code>
              <button
                @click="copyToClipboard(ticketKey, 'key')"
                class="p-2 text-neutral-400 hover:text-white hover:bg-neutral-700 rounded transition-colors flex-shrink-0"
                :title="copied === 'key' ? '¡Copiado!' : 'Copiar'"
              >
                <svg v-if="copied !== 'key'" class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                </svg>
                <svg v-else class="w-4 h-4 text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                </svg>
              </button>
            </div>
          </div>

          <div>
            <p class="text-xs text-neutral-400 mb-2 uppercase tracking-wide">Copiar confirmación Git de ejemplo</p>
            <div class="flex items-center gap-2">
              <code class="flex-1 text-xs bg-neutral-900 text-neutral-200 p-2 rounded font-mono overflow-x-auto">
                {{ gitCommitCommand }}
              </code>
              <button
                @click="copyToClipboard(gitCommitCommand, 'commit')"
                class="p-2 text-neutral-400 hover:text-white hover:bg-neutral-700 rounded transition-colors flex-shrink-0"
                :title="copied === 'commit' ? '¡Copiado!' : 'Copiar'"
              >
                <svg v-if="copied !== 'commit'" class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                </svg>
                <svg v-else class="w-4 h-4 text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                </svg>
              </button>
            </div>
          </div>

          <p class="text-xs text-neutral-500">
            Comando para Bash o Git Bash. Incluye la clave de la tarea en el mensaje.
          </p>
        </div>
      </div>
    </div>
  </div>
</template>
