<template>
  <div class="flex flex-col h-full">
    <!-- Header -->
    <div class="flex items-center justify-between mb-4">
      <h3 class="text-lg font-bold">Actividad del proyecto</h3>
      <button
        @click="$emit('close')"
        class="p-2 -mr-2 text-neutral-400 hover:text-white"
      >
        <svg
          class="w-5 h-5"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="1.5"
            d="M6 18L18 6M6 6l12 12"
          />
        </svg>
      </button>
    </div>

    <!-- Filtros -->
    <div class="flex flex-wrap gap-2 mb-4">
      <button
        v-for="filter in filters"
        :key="filter.value"
        @click="toggleFilter(filter.value)"
        class="text-xs px-3 py-1.5 rounded-full border transition-colors"
        :class="
          activeFilters.includes(filter.value)
            ? 'bg-cyan-500/20 border-cyan-500 text-cyan-400'
            : 'border-neutral-700 text-neutral-400 hover:border-neutral-600'
        "
      >
        {{ filter.label }}
      </button>
    </div>

    <!-- Filtro por usuario -->
    <div class="mb-4">
      <select v-model="filterByUser" class="input text-sm w-full">
        <option value="">Todos los usuarios</option>
        <option v-for="user in users" :key="user.id" :value="user.id">
          {{ user.full_name || user.email }}
        </option>
      </select>
    </div>

    <!-- Lista de actividades -->
    <div v-if="loading" class="text-sm text-neutral-500 py-8 text-center">
      Cargando actividad...
    </div>

    <div
      v-else-if="filteredActivities.length === 0"
      class="text-sm text-neutral-500 py-8 text-center"
    >
      No hay actividad registrada
    </div>

    <div v-else class="flex-1 overflow-y-auto space-y-1 pr-1">
      <!-- Agrupar por fecha -->
      <div v-for="(group, date) in groupedActivities" :key="date">
        <div class="sticky top-0 bg-neutral-950 py-2 z-10">
          <span class="text-xs font-medium text-neutral-500 uppercase">{{
            date
          }}</span>
        </div>

        <div
          v-for="activity in group"
          :key="activity.id"
          @click="goToTask(activity)"
          class="flex gap-3 p-3 rounded-lg hover:bg-neutral-800/50 cursor-pointer transition-colors"
        >
          <!-- Icono -->
          <div class="flex-shrink-0">
            <div
              class="w-8 h-8 rounded-full flex items-center justify-center"
              :class="getActionIconClass(activity.action)"
            >
              <svg
                v-if="activity.action === 'created'"
                class="w-4 h-4"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 4v16m8-8H4"
                />
              </svg>
              <svg
                v-else-if="activity.action === 'status_changed'"
                class="w-4 h-4"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M13 7l5 5m0 0l-5 5m5-5H6"
                />
              </svg>
              <svg
                v-else-if="activity.action === 'assigned'"
                class="w-4 h-4"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z"
                />
              </svg>
              <svg
                v-else-if="activity.action === 'unassigned'"
                class="w-4 h-4"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M13 7a4 4 0 11-8 0 4 4 0 018 0zM9 14a6 6 0 00-6 6v1h12v-1a6 6 0 00-6-6zM21 12h-6"
                />
              </svg>
              <svg
                v-else-if="
                  activity.action === 'label_added' ||
                  activity.action === 'label_removed'
                "
                class="w-4 h-4"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"
                />
              </svg>
              <svg
                v-else-if="activity.action === 'updated'"
                class="w-4 h-4"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"
                />
              </svg>
              <svg
                v-else-if="activity.action === 'deleted'"
                class="w-4 h-4"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                />
              </svg>
              <svg
                v-else
                class="w-4 h-4"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
            </div>
          </div>

          <!-- Contenido -->
          <div class="flex-1 min-w-0">
            <p class="text-sm text-neutral-300">
              <span class="font-medium text-white">{{
                activity.user_name || "Sistema"
              }}</span>
              {{ getActionText(activity) }}
            </p>
            <p
              v-if="activity.task_title"
              class="text-xs text-cyan-400 mt-0.5 truncate"
            >
              {{ activity.task_title }}
            </p>
            <p class="text-xs text-neutral-500 mt-0.5">
              {{ formatTime(activity.created_at) }}
            </p>
          </div>
        </div>
      </div>

      <!-- Cargar más -->
      <button
        v-if="hasMore"
        @click="loadMore"
        class="w-full py-3 text-sm text-cyan-400 hover:text-cyan-300 text-center"
      >
        Cargar más actividad
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
const props = defineProps<{
  projectId: string;
  members: any[];
}>();

const emit = defineEmits(["close", "select-task"]);

const supabase = useSupabaseClient();

const activities = ref<any[]>([]);
const loading = ref(true);
const page = ref(0);
const pageSize = 50;
const hasMore = ref(true);

const filters = [
  { label: "Creadas", value: "created" },
  { label: "Movidas", value: "status_changed" },
  { label: "Asignadas", value: "assigned" },
  { label: "Etiquetas", value: "label_added,label_removed" },
  { label: "Editadas", value: "updated" },
];

const activeFilters = ref<string[]>([]);
const filterByUser = ref("");

const users = computed(() => {
  const uniqueUsers = new Map();
  props.members.forEach((m) => {
    uniqueUsers.set(m.user_id, {
      id: m.user_id,
      full_name: m.full_name,
      email: m.email,
    });
  });
  return Array.from(uniqueUsers.values());
});

const toggleFilter = (value: string) => {
  const index = activeFilters.value.indexOf(value);
  if (index > -1) {
    activeFilters.value.splice(index, 1);
  } else {
    activeFilters.value.push(value);
  }
};

const filteredActivities = computed(() => {
  let result = activities.value;

  // Filtrar por tipo de acción
  if (activeFilters.value.length > 0) {
    const actionTypes = activeFilters.value.flatMap((f) => f.split(","));
    result = result.filter((a) => actionTypes.includes(a.action));
  }

  // Filtrar por usuario
  if (filterByUser.value) {
    result = result.filter((a) => a.user_id === filterByUser.value);
  }

  return result;
});

const groupedActivities = computed(() => {
  const groups: Record<string, any[]> = {};

  filteredActivities.value.forEach((activity) => {
    const date = formatDateGroup(activity.created_at);
    if (!groups[date]) {
      groups[date] = [];
    }
    groups[date].push(activity);
  });

  return groups;
});

const loadActivities = async (append = false) => {
  if (!props.projectId) return;

  if (!append) {
    loading.value = true;
    page.value = 0;
  }

  const from = page.value * pageSize;
  const to = from + pageSize - 1;

  const { data, error } = await supabase
    .from("task_activities")
    .select(
      `
      *,
      profiles!user_id (full_name, email),
      tasks!task_id (title)
    `
    )
    .eq("project_id", props.projectId)
    .order("created_at", { ascending: false })
    .range(from, to);

  if (data) {
    const mapped = data.map((a) => ({
      ...a,
      user_name: a.profiles?.full_name || a.profiles?.email || null,
      task_title: a.task_title || a.tasks?.title || null,
    }));

    if (append) {
      activities.value.push(...mapped);
    } else {
      activities.value = mapped;
    }

    hasMore.value = data.length === pageSize;
  }

  loading.value = false;
};

const loadMore = () => {
  page.value++;
  loadActivities(true);
};

const goToTask = (activity: any) => {
  if (activity.task_id) {
    emit("select-task", activity.task_id);
  }
};

const getActionIconClass = (action: string) => {
  const classes: Record<string, string> = {
    created: "bg-green-500/20 text-green-400",
    status_changed: "bg-blue-500/20 text-blue-400",
    assigned: "bg-cyan-500/20 text-cyan-400",
    unassigned: "bg-orange-500/20 text-orange-400",
    label_added: "bg-purple-500/20 text-purple-400",
    label_removed: "bg-purple-500/20 text-purple-400",
    updated: "bg-yellow-500/20 text-yellow-400",
    deleted: "bg-red-500/20 text-red-400",
  };
  return classes[action] || "bg-neutral-700 text-neutral-400";
};

const getActionText = (activity: any) => {
  const action = activity.action;
  const field = activity.field_name;
  const oldVal = activity.old_value;
  const newVal = activity.new_value;

  switch (action) {
    case "created":
      return " creó una tarea";
    case "status_changed":
      return ` movió de "${oldVal}" a "${newVal}"`;
    case "assigned":
      return ` asignó a ${newVal}`;
    case "unassigned":
      return ` removió a ${oldVal}`;
    case "label_added":
      return ` agregó "${newVal}"`;
    case "label_removed":
      return ` quitó "${oldVal}"`;
    case "updated":
      if (field === "title") return " cambió el título";
      if (field === "description") return " actualizó la descripción";
      if (field === "priority")
        return ` cambió prioridad a "${formatPriority(newVal)}"`;
      return ` actualizó ${field}`;
    case "deleted":
      return " eliminó una tarea";
    default:
      return ` ${action}`;
  }
};

const formatPriority = (priority: string) => {
  const map: Record<string, string> = {
    low: "Baja",
    medium: "Media",
    high: "Alta",
    urgent: "Urgente",
  };
  return map[priority] || priority;
};

const formatDateGroup = (date: string) => {
  const d = new Date(date);
  const now = new Date();
  const diff = now.getTime() - d.getTime();
  const days = Math.floor(diff / 86400000);

  if (days === 0) return "Hoy";
  if (days === 1) return "Ayer";
  if (days < 7) return `Hace ${days} días`;

  return d.toLocaleDateString("es-MX", { day: "numeric", month: "long" });
};

const formatTime = (date: string) => {
  return new Date(date).toLocaleTimeString("es-MX", {
    hour: "2-digit",
    minute: "2-digit",
  });
};

// Cargar al montar
onMounted(() => {
  loadActivities();
});

// Recargar si cambia el proyecto
watch(
  () => props.projectId,
  () => {
    loadActivities();
  }
);

defineExpose({ refresh: () => loadActivities() });
</script>
