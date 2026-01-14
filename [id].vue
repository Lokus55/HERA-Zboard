<template>
  <div class="min-h-screen flex flex-col lg:flex-row">
    <!-- Mobile Header -->
    <header
      class="lg:hidden border-b border-neutral-800 p-4 flex items-center justify-between"
    >
      <button @click="sidebarOpen = true" class="p-2 -ml-2">
        <svg
          class="w-6 h-6"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="1.5"
            d="M4 6h16M4 12h16M4 18h16"
          />
        </svg>
      </button>
      <div class="flex items-center gap-2">
        <div
          class="w-8 h-8 rounded-lg flex items-center justify-center text-neutral-950 font-bold text-sm"
          :style="{ backgroundColor: project?.color || '#06b6d4' }"
        >
          {{ project?.name?.charAt(0) || "P" }}
        </div>
        <span class="font-semibold truncate max-w-[150px]">{{
          project?.name
        }}</span>
      </div>
      <button @click="openNewTask" class="p-2 -mr-2 text-cyan-400">
        <svg
          class="w-6 h-6"
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
      </button>
    </header>

    <div
      v-if="sidebarOpen"
      class="fixed inset-0 bg-black/60 z-40 lg:hidden"
      @click="sidebarOpen = false"
    />

    <!-- Sidebar -->
    <aside
      class="fixed lg:relative inset-y-0 left-0 z-50 w-72 lg:w-64 border-r border-neutral-800 p-4 flex flex-col bg-neutral-950 transform transition-transform duration-300 lg:transform-none overflow-y-auto"
      :class="
        sidebarOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'
      "
    >
      <div class="flex items-center justify-between mb-8">
        <NuxtLink to="/dashboard" class="flex items-center gap-3">
          <div
            class="w-8 h-8 rounded-lg bg-gradient-to-br from-cyan-400 to-cyan-600 flex items-center justify-center"
          >
            <span class="text-neutral-950 font-bold text-sm">Z</span>
          </div>
          <span class="font-bold">Zboard</span>
        </NuxtLink>
        <button @click="sidebarOpen = false" class="lg:hidden p-2 -mr-2">
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

      <nav class="flex-1 space-y-1">
        <NuxtLink
          to="/dashboard"
          class="sidebar-item"
          @click="sidebarOpen = false"
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
              d="M10 19l-7-7m0 0l7-7m-7 7h18"
            />
          </svg>
          Volver al Dashboard
        </NuxtLink>

        <div class="pt-4 pb-2">
          <span class="px-3 text-xs font-medium text-neutral-500 uppercase"
            >Filtrar por usuario</span
          >
        </div>
        <button
          @click="
            filterByUser = null;
            sidebarOpen = false;
          "
          class="sidebar-item w-full text-left"
          :class="{ 'sidebar-item-active': filterByUser === null }"
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
              d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"
            />
          </svg>
          Todos
        </button>

        <div class="pt-2 pb-2">
          <span class="px-3 text-xs font-medium text-neutral-500 uppercase"
            >Equipo</span
          >
        </div>
        <button
          v-for="member in members"
          :key="member.user_id"
          @click="
            filterByUser = member.user_id;
            sidebarOpen = false;
          "
          class="sidebar-item w-full text-left"
          :class="{ 'sidebar-item-active': filterByUser === member.user_id }"
        >
          <div
            class="w-6 h-6 rounded-full flex items-center justify-center text-xs text-white flex-shrink-0"
            :style="{ backgroundColor: getAvatarColor(member.user_id) }"
          >
            {{ getInitials(member.full_name || member.email) }}
          </div>
          <span class="truncate">{{
            member.full_name || member.email?.split("@")[0]
          }}</span>
        </button>
        <button
          @click="
            showInvite = true;
            sidebarOpen = false;
          "
          class="sidebar-item w-full text-left text-cyan-400"
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
              d="M12 4v16m8-8H4"
            />
          </svg>
          Invitar miembro
        </button>

        <div class="pt-4 pb-2">
          <span class="px-3 text-xs font-medium text-neutral-500 uppercase"
            >Etiquetas</span
          >
        </div>
        <button
          @click="
            filterByLabel = null;
            sidebarOpen = false;
          "
          class="sidebar-item w-full text-left"
          :class="{ 'sidebar-item-active': filterByLabel === null }"
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
              d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"
            />
          </svg>
          Todas
        </button>
        <div
          v-for="label in labels"
          :key="label.id"
          class="sidebar-item w-full text-left group"
          :class="{ 'sidebar-item-active': filterByLabel === label.id }"
        >
          <button
            @click="
              filterByLabel = label.id;
              sidebarOpen = false;
            "
            class="flex items-center gap-2 flex-1 min-w-0"
          >
            <div
              class="w-3 h-3 rounded-full flex-shrink-0"
              :style="{ backgroundColor: label.color }"
            />
            <span class="truncate">{{ label.name }}</span>
          </button>
          <button
            @click="openEditLabel(label, $event)"
            class="p-1 opacity-0 group-hover:opacity-100 text-neutral-500 hover:text-white transition-opacity"
          >
            <svg
              class="w-4 h-4"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="1.5"
                d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"
              />
            </svg>
          </button>
        </div>
        <button
          @click="openNewLabel"
          class="sidebar-item w-full text-left text-cyan-400"
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
              d="M12 4v16m8-8H4"
            />
          </svg>
          Nueva etiqueta
        </button>

        <div class="pt-4 pb-2">
          <span class="px-3 text-xs font-medium text-neutral-500 uppercase"
            >Documentos</span
          >
        </div>
        <button
          v-for="doc in documents"
          :key="doc.id"
          @click="openViewDocument(doc)"
          class="sidebar-item w-full text-left group"
        >
          <svg
            class="w-5 h-5 flex-shrink-0 text-neutral-400"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="1.5"
              d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
            />
          </svg>
          <span class="truncate flex-1">{{ doc.title }}</span>
          <span class="text-xs text-neutral-500">@{{ doc.slug }}</span>
        </button>
        <button
          @click="openNewDocument"
          class="sidebar-item w-full text-left text-cyan-400"
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
              d="M12 4v16m8-8H4"
            />
          </svg>
          Nuevo documento
        </button>
        <div class="pt-4 pb-2">
          <span class="px-3 text-xs font-medium text-neutral-500 uppercase"
            >Actividad</span
          >
        </div>
        <button
          @click="
            showActivityPanel = true;
            sidebarOpen = false;
          "
          class="sidebar-item w-full text-left"
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
              d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
            />
          </svg>
          Ver historial
        </button>
      </nav>
    </aside>

    <!-- Main -->
    <main class="flex-1 flex flex-col overflow-hidden">
      <header class="hidden lg:block border-b border-neutral-800 p-4">
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-3">
            <div
              class="w-10 h-10 rounded-lg flex items-center justify-center text-neutral-950 font-bold"
              :style="{ backgroundColor: project?.color || '#06b6d4' }"
            >
              {{ project?.name?.charAt(0) || "P" }}
            </div>
            <div>
              <h1 class="text-xl font-bold">
                {{ project?.name || "Cargando..." }}
              </h1>
              <p class="text-sm text-neutral-400">
                {{ filteredTasks.length }} tareas<span
                  v-if="filterByUser"
                  class="text-cyan-400"
                >
                  · {{ getMemberName(filterByUser) }}</span
                ><span v-if="filterByLabel" class="text-cyan-400">
                  · {{ getLabelName(filterByLabel) }}</span
                >
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

      <div
        class="lg:hidden border-b border-neutral-800 p-3 flex items-center gap-2"
      >
        <span class="text-xs text-neutral-500"
          >{{ filteredTasks.length }} tareas</span
        >
        <div class="flex-1" />
        <button
          @click="showAddColumn = true"
          class="btn-secondary text-sm py-1.5 px-3"
        >
          + Columna
        </button>
      </div>

      <div class="flex-1 overflow-x-auto p-4 lg:p-6">
        <div
          v-if="statuses.length === 0"
          class="text-neutral-400 text-center py-8"
        >
          Cargando...
        </div>
        <div
          v-else
          class="flex gap-3 lg:gap-4 h-full min-h-[400px]"
          :style="{ minWidth: statuses.length * 280 + 'px' }"
        >
          <div
            v-for="column in statuses"
            :key="column.id"
            class="w-[260px] sm:w-[280px] lg:w-80 flex-shrink-0"
          >
            <div
              class="bg-neutral-900/50 rounded-xl p-2 sm:p-3 h-full flex flex-col"
            >
              <div class="flex items-center justify-between mb-3 px-1">
                <div class="flex items-center gap-2">
                  <div
                    class="w-3 h-3 rounded-full"
                    :style="{ backgroundColor: column.color }"
                  />
                  <h3 class="font-medium text-sm lg:text-base">
                    {{ column.name }}
                  </h3>
                  <span
                    class="text-xs text-neutral-500 bg-neutral-800 px-1.5 py-0.5 rounded"
                    >{{ getTasksByStatus(column.id).length }}</span
                  >
                </div>
                <button
                  v-if="!isDefaultColumn(column.name)"
                  @click="editColumn(column)"
                  class="text-neutral-500 hover:text-neutral-300 p-1"
                >
                  <svg
                    class="w-4 h-4"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="1.5"
                      d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z"
                    />
                  </svg>
                </button>
              </div>
              <draggable
                :list="getTasksByStatus(column.id)"
                group="tasks"
                item-key="id"
                class="flex-1 space-y-2 min-h-[100px] overflow-y-auto"
                @change="(e) => onDragChange(e, column.id)"
              >
                <template #item="{ element }">
                  <div
                    @click="openEditTask(element)"
                    class="card p-3 lg:p-4 cursor-pointer hover:border-neutral-700 transition-colors active:scale-[0.98]"
                  >
                    <h4
                      class="font-medium text-sm lg:text-base mb-2 line-clamp-2"
                    >
                      {{ element.title }}
                    </h4>
                    <div
                      v-if="element.labels?.length"
                      class="flex flex-wrap gap-1 mb-2"
                    >
                      <span
                        v-for="label in element.labels"
                        :key="label.id"
                        class="text-[10px] px-1.5 py-0.5 rounded-full text-white"
                        :style="{ backgroundColor: label.color }"
                        >{{ label.name }}</span
                      >
                    </div>
                    <p
                      v-if="element.description"
                      class="text-xs text-neutral-400 mb-2 line-clamp-2"
                      v-html="renderDescription(element.description)"
                      @click.stop="handleDescriptionClick($event)"
                    />
                    <div class="flex items-center justify-between">
                      <span
                        class="text-xs px-2 py-0.5 rounded-full"
                        :class="priorityClass(element.priority)"
                        >{{ priorityLabel(element.priority) }}</span
                      >
                      <div
                        class="flex -space-x-1.5"
                        v-if="element.assignees?.length"
                      >
                        <div
                          v-for="(assignee, idx) in element.assignees.slice(
                            0,
                            3
                          )"
                          :key="assignee.user_id"
                          class="w-5 h-5 lg:w-6 lg:h-6 rounded-full border-2 border-neutral-900 flex items-center justify-center text-[10px] lg:text-xs text-white"
                          :style="{
                            backgroundColor: getAvatarColor(assignee.user_id),
                            zIndex: 3 - idx,
                          }"
                        >
                          {{
                            getInitials(assignee.full_name || assignee.email)
                          }}
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

    <!-- Modal Tarea -->
    <div
      v-if="showTaskModal"
      class="fixed inset-0 bg-black/60 flex items-end sm:items-center justify-center p-0 sm:p-4 z-50"
    >
      <div
        class="card p-4 sm:p-6 w-full sm:max-w-md max-h-[90vh] overflow-y-auto rounded-t-2xl sm:rounded-xl"
      >
        <div class="flex items-center justify-between mb-4">
          <h2 class="text-lg font-bold">
            {{ editingTask ? "Editar tarea" : "Nueva tarea" }}
          </h2>
          <button
            @click="closeTaskModal"
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
        <form @submit.prevent="saveTask" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5"
              >Título</label
            ><input
              v-model="taskForm.title"
              type="text"
              class="input"
              placeholder="¿Qué hay que hacer?"
              required
            />
          </div>
          <div class="relative">
            <label class="block text-sm font-medium text-neutral-400 mb-1.5"
              >Descripción</label
            >
            <textarea
              ref="descriptionInput"
              v-model="taskForm.description"
              class="input"
              rows="3"
              placeholder="Usa @documento para referencias"
              @input="onDescriptionInput"
              @keydown="onDescriptionKeydown"
            ></textarea>
            <p class="text-xs text-neutral-500 mt-1">
              Escribe @ para insertar documentos
            </p>
            <div
              v-if="showAutocomplete && filteredDocuments.length > 0"
              class="absolute left-0 right-0 mt-1 bg-neutral-800 border border-neutral-700 rounded-lg overflow-hidden z-10"
            >
              <button
                v-for="(doc, idx) in filteredDocuments"
                :key="doc.id"
                type="button"
                @click="insertDocumentReference(doc)"
                class="w-full px-3 py-2 text-left text-sm hover:bg-neutral-700 flex items-center gap-2"
                :class="{ 'bg-neutral-700': idx === autocompleteIndex }"
              >
                <svg
                  class="w-4 h-4 text-neutral-400"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="1.5"
                    d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                  />
                </svg>
                <span>{{ doc.title }}</span
                ><span class="text-neutral-500 text-xs">@{{ doc.slug }}</span>
              </button>
            </div>
          </div>
          <div class="grid grid-cols-2 gap-3">
            <div>
              <label class="block text-sm font-medium text-neutral-400 mb-1.5"
                >Estado</label
              ><select v-model="taskForm.status_id" class="input text-sm">
                <option v-for="col in statuses" :key="col.id" :value="col.id">
                  {{ col.name }}
                </option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-neutral-400 mb-1.5"
                >Prioridad</label
              ><select v-model="taskForm.priority" class="input text-sm">
                <option value="low">Baja</option>
                <option value="medium">Media</option>
                <option value="high">Alta</option>
              </select>
            </div>
          </div>
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5"
              >Etiquetas</label
            >
            <div class="flex flex-wrap gap-2">
              <button
                v-for="label in labels"
                :key="label.id"
                type="button"
                @click="toggleLabel(label.id)"
                class="text-xs px-2 py-1 rounded-full border transition-colors"
                :class="
                  taskForm.label_ids.includes(label.id)
                    ? 'text-white border-transparent'
                    : 'text-neutral-400 border-neutral-700'
                "
                :style="
                  taskForm.label_ids.includes(label.id)
                    ? { backgroundColor: label.color }
                    : {}
                "
              >
                {{ label.name }}
              </button>
            </div>
          </div>
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5"
              >Asignar a</label
            >
            <div class="space-y-1 max-h-32 overflow-y-auto">
              <label
                v-for="member in members"
                :key="member.user_id"
                class="flex items-center gap-3 p-2 rounded-lg hover:bg-neutral-800 cursor-pointer"
                ><input
                  type="checkbox"
                  :value="member.user_id"
                  v-model="taskForm.assignee_ids"
                  class="w-4 h-4 rounded border-neutral-600 text-cyan-500"
                />
                <div
                  class="w-6 h-6 rounded-full flex items-center justify-center text-xs text-white"
                  :style="{ backgroundColor: getAvatarColor(member.user_id) }"
                >
                  {{ getInitials(member.full_name || member.email) }}
                </div>
                <span class="text-sm truncate">{{
                  member.full_name || member.email?.split("@")[0]
                }}</span></label
              >
            </div>
          </div>
          <div class="flex gap-3 pt-2">
            <button
              v-if="editingTask"
              type="button"
              @click="deleteTask"
              class="btn-secondary text-red-400 text-sm"
            >
              Eliminar
            </button>
            <div class="flex-1"></div>
            <button
              type="button"
              @click="closeTaskModal"
              class="btn-secondary text-sm"
            >
              Cancelar
            </button>
            <button type="submit" class="btn-primary text-sm">
              {{ editingTask ? "Guardar" : "Crear" }}
            </button>
          </div>
        </form>

        <!-- Historial de actividad (solo al editar) -->
        <div v-if="editingTask" class="border-t border-neutral-800 pt-4 mt-4">
          <TaskTaskactivitylog :task-id="editingTask.id" ref="activityLog" />
        </div>
      </div>
    </div>
    <!-- Modal Etiqueta -->
    <div
      v-if="showAddLabel"
      class="fixed inset-0 bg-black/60 flex items-end sm:items-center justify-center p-0 sm:p-4 z-50"
    >
      <div
        class="card p-4 sm:p-6 w-full sm:max-w-sm rounded-t-2xl sm:rounded-xl"
      >
        <div class="flex items-center justify-between mb-4">
          <h2 class="text-lg font-bold">
            {{ editingLabel ? "Editar etiqueta" : "Nueva etiqueta" }}
          </h2>
          <button
            @click="closeLabelModal"
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
        <form @submit.prevent="saveLabel" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5"
              >Nombre</label
            ><input
              v-model="labelForm.name"
              type="text"
              class="input"
              placeholder="frontend, bug..."
              required
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5"
              >Color</label
            >
            <div class="flex gap-2 flex-wrap">
              <button
                v-for="color in labelColors"
                :key="color"
                type="button"
                @click="labelForm.color = color"
                class="w-8 h-8 rounded-lg hover:scale-110"
                :class="{ 'ring-2 ring-white': labelForm.color === color }"
                :style="{ backgroundColor: color }"
              />
            </div>
          </div>
          <div class="flex gap-3 pt-2">
            <button
              v-if="editingLabel"
              type="button"
              @click="deleteLabel"
              class="btn-secondary text-red-400 text-sm"
            >
              Eliminar
            </button>
            <div class="flex-1"></div>
            <button
              type="button"
              @click="closeLabelModal"
              class="btn-secondary text-sm"
            >
              Cancelar</button
            ><button type="submit" class="btn-primary text-sm">
              {{ editingLabel ? "Guardar" : "Crear" }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Modal Columna -->
    <div
      v-if="showAddColumn"
      class="fixed inset-0 bg-black/60 flex items-end sm:items-center justify-center p-0 sm:p-4 z-50"
    >
      <div
        class="card p-4 sm:p-6 w-full sm:max-w-sm rounded-t-2xl sm:rounded-xl"
      >
        <div class="flex items-center justify-between mb-4">
          <h2 class="text-lg font-bold">
            {{ editingColumn ? "Editar columna" : "Nueva columna" }}
          </h2>
          <button
            @click="closeColumnModal"
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
        <form @submit.prevent="saveColumn" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5"
              >Nombre</label
            ><input
              v-model="columnForm.name"
              type="text"
              class="input"
              placeholder="Nombre"
              required
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5"
              >Color</label
            >
            <div class="flex gap-2 flex-wrap">
              <button
                v-for="color in columnColors"
                :key="color"
                type="button"
                @click="columnForm.color = color"
                class="w-8 h-8 rounded-lg hover:scale-110"
                :class="{ 'ring-2 ring-white': columnForm.color === color }"
                :style="{ backgroundColor: color }"
              />
            </div>
          </div>
          <div class="flex gap-3 pt-2">
            <button
              v-if="editingColumn"
              type="button"
              @click="deleteColumn"
              class="btn-secondary text-red-400 text-sm"
            >
              Eliminar
            </button>
            <div class="flex-1"></div>
            <button
              type="button"
              @click="closeColumnModal"
              class="btn-secondary text-sm"
            >
              Cancelar</button
            ><button type="submit" class="btn-primary text-sm">
              {{ editingColumn ? "Guardar" : "Crear" }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Modal Invitar -->
    <div
      v-if="showInvite"
      class="fixed inset-0 bg-black/60 flex items-end sm:items-center justify-center p-0 sm:p-4 z-50"
    >
      <div
        class="card p-4 sm:p-6 w-full sm:max-w-md rounded-t-2xl sm:rounded-xl"
      >
        <div class="flex items-center justify-between mb-4">
          <h2 class="text-lg font-bold">Invitar al workspace</h2>
          <button
            @click="showInvite = false"
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
        <form @submit.prevent="inviteMember" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5"
              >Email</label
            ><input
              v-model="inviteEmail"
              type="email"
              class="input"
              placeholder="email@ejemplo.com"
              required
            />
          </div>
          <p class="text-sm text-neutral-500">
            El usuario debe estar registrado.
          </p>
          <div v-if="inviteError" class="text-red-400 text-sm">
            {{ inviteError }}
          </div>
          <div v-if="inviteSuccess" class="text-green-400 text-sm">
            {{ inviteSuccess }}
          </div>
          <div class="flex gap-3 pt-2">
            <button
              type="button"
              @click="showInvite = false"
              class="btn-secondary flex-1 text-sm"
            >
              Cancelar</button
            ><button type="submit" class="btn-primary flex-1 text-sm">
              Invitar
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Modal Documento -->
    <div
      v-if="showDocumentModal"
      class="fixed inset-0 bg-black/60 flex items-end sm:items-center justify-center p-0 sm:p-4 z-50"
    >
      <div
        class="card p-4 sm:p-6 w-full sm:max-w-lg max-h-[90vh] overflow-y-auto rounded-t-2xl sm:rounded-xl"
      >
        <div class="flex items-center justify-between mb-4">
          <h2 class="text-lg font-bold">
            {{ editingDocument ? "Editar documento" : "Nuevo documento" }}
          </h2>
          <button
            @click="closeDocumentModal"
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
        <form @submit.prevent="saveDocument" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5"
              >Título</label
            ><input
              v-model="documentForm.title"
              type="text"
              class="input"
              placeholder="Titulo del documento"
              required
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5"
              >Slug (para @)</label
            >
            <div class="flex items-center gap-2">
              <span class="text-neutral-500">@</span
              ><input
                v-model="documentForm.slug"
                type="text"
                class="input flex-1"
                placeholder="slug-del-documento"
                @input="sanitizeSlug"
                required
              />
            </div>
            <p class="text-xs text-neutral-500 mt-1">Sin espacios</p>
          </div>
          <div>
            <label class="block text-sm font-medium text-neutral-400 mb-1.5"
              >Contenido</label
            ><textarea
              v-model="documentForm.content"
              class="input font-mono text-sm"
              rows="10"
              placeholder="Email: user@gmail.com
Password: 123456"
            ></textarea>
          </div>
          <div class="flex gap-3 pt-2">
            <button
              v-if="editingDocument"
              type="button"
              @click="deleteDocument"
              class="btn-secondary text-red-400 text-sm"
            >
              Eliminar
            </button>
            <div class="flex-1"></div>
            <button
              type="button"
              @click="closeDocumentModal"
              class="btn-secondary text-sm"
            >
              Cancelar</button
            ><button type="submit" class="btn-primary text-sm">
              {{ editingDocument ? "Guardar" : "Crear" }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Modal Ver Documento -->
    <div
      v-if="showViewDocument"
      class="fixed inset-0 bg-black/60 flex items-end sm:items-center justify-center p-0 sm:p-4 z-50"
    >
      <div
        class="card p-4 sm:p-6 w-full sm:max-w-lg max-h-[90vh] overflow-y-auto rounded-t-2xl sm:rounded-xl"
      >
        <div class="flex items-center justify-between mb-4">
          <div>
            <h2 class="text-lg font-bold">{{ viewingDocument?.title }}</h2>
            <p class="text-sm text-neutral-500">@{{ viewingDocument?.slug }}</p>
          </div>
          <div class="flex items-center gap-2">
            <button
              @click="openEditDocument(viewingDocument)"
              class="p-2 text-neutral-400 hover:text-white"
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
                  d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"
                />
              </svg>
            </button>
            <button
              @click="showViewDocument = false"
              class="p-2 text-neutral-400 hover:text-white"
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
        </div>
        <div
          class="bg-neutral-800/50 rounded-lg p-4 font-mono text-sm whitespace-pre-wrap"
        >
          {{ viewingDocument?.content }}
        </div>
        <div class="flex justify-end gap-2 mt-4">
          <button
            @click="copyDocumentContent"
            class="btn-secondary text-sm flex items-center gap-1"
          >
            <svg
              class="w-4 h-4"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="1.5"
                d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z"
              /></svg
            >{{ copied ? "Copiado!" : "Copiar" }}
          </button>
          <button @click="showViewDocument = false" class="btn-primary text-sm">
            Cerrar
          </button>
        </div>
      </div>
    </div>
    <!-- Panel de Actividad -->
    <div
      v-if="showActivityPanel"
      class="fixed inset-0 bg-black/60 flex items-end sm:items-center justify-center p-0 sm:p-4 z-50"
    >
      <div
        class="card p-4 sm:p-6 w-full sm:max-w-lg h-[85vh] sm:h-[80vh] rounded-t-2xl sm:rounded-xl flex flex-col"
      >
        <TaskProjectActivityPanel
          :project-id="projectId"
          :members="members"
          @close="showActivityPanel = false"
          @select-task="openTaskFromActivity"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import draggable from "vuedraggable";

definePageMeta({ middleware: "auth" });

const route = useRoute();
const supabase = useSupabaseClient();
const user = useSupabaseUser();

const projectId = route.params.id as string;
const project = ref<any>(null);
const tasks = ref<any[]>([]);
const statuses = ref<any[]>([]);
const members = ref<any[]>([]);
const labels = ref<any[]>([]);
const documents = ref<any[]>([]);
const filterByUser = ref<string | null>(null);
const filterByLabel = ref<string | null>(null);
const sidebarOpen = ref(false);

const showTaskModal = ref(false);
const editingTask = ref<any>(null);
const taskForm = ref({
  title: "",
  description: "",
  status_id: "",
  priority: "medium",
  assignee_ids: [] as string[],
  label_ids: [] as string[],
});

const descriptionInput = ref<HTMLTextAreaElement | null>(null);
const showAutocomplete = ref(false);
const autocompleteIndex = ref(0);
const autocompleteQuery = ref("");
const filteredDocuments = computed(() => {
  if (!autocompleteQuery.value) return documents.value;
  const q = autocompleteQuery.value.toLowerCase();
  return documents.value.filter(
    (d) => d.title.toLowerCase().includes(q) || d.slug.toLowerCase().includes(q)
  );
});

const showActivityPanel = ref(false);

const showAddLabel = ref(false);
const editingLabel = ref<any>(null);
const labelForm = ref({ name: "", color: "#6366f1" });
const labelColors = [
  "#ef4444",
  "#f59e0b",
  "#10b981",
  "#06b6d4",
  "#6366f1",
  "#8b5cf6",
  "#ec4899",
  "#78716c",
];

const showAddColumn = ref(false);
const editingColumn = ref<any>(null);
const columnForm = ref({ name: "", color: "#78716c" });
const columnColors = [
  "#78716c",
  "#ef4444",
  "#f59e0b",
  "#10b981",
  "#06b6d4",
  "#8b5cf6",
  "#ec4899",
];
const defaultColumns = [
  "Por hacer",
  "En progreso",
  "En revisión",
  "Completado",
];

const showInvite = ref(false);
const inviteEmail = ref("");
const inviteError = ref("");
const inviteSuccess = ref("");

const showDocumentModal = ref(false);
const showViewDocument = ref(false);
const editingDocument = ref<any>(null);
const viewingDocument = ref<any>(null);
const documentForm = ref({ title: "", slug: "", content: "" });
const copied = ref(false);

const filteredTasks = computed(() => {
  let result = tasks.value;
  if (filterByUser.value)
    result = result.filter((t) =>
      t.assignees?.some((a: any) => a.user_id === filterByUser.value)
    );
  if (filterByLabel.value)
    result = result.filter((t) =>
      t.labels?.some((l: any) => l.id === filterByLabel.value)
    );
  return result;
});

const getTasksByStatus = (statusId: string) =>
  filteredTasks.value.filter((t) => t.status_id === statusId);
const isDefaultColumn = (name: string) => defaultColumns.includes(name);
const getAvatarColor = (userId: string) =>
  ["#ef4444", "#f59e0b", "#10b981", "#06b6d4", "#8b5cf6", "#ec4899", "#6366f1"][
    userId.charCodeAt(0) % 7
  ];
const getInitials = (name: string) =>
  name
    ? name
        .split(" ")
        .map((n) => n[0])
        .join("")
        .toUpperCase()
        .slice(0, 2)
    : "?";
const getMemberName = (userId: string) => {
  const m = members.value.find((m) => m.user_id === userId);
  return m?.full_name || m?.email?.split("@")[0] || "Usuario";
};
const getLabelName = (labelId: string) =>
  labels.value.find((l) => l.id === labelId)?.name || "Etiqueta";
const priorityClass = (p: string) => ({
  "bg-red-500/20 text-red-400": p === "high",
  "bg-amber-500/20 text-amber-400": p === "medium",
  "bg-neutral-700 text-neutral-400": p === "low",
});
const priorityLabel = (p: string) =>
  ({ high: "Alta", medium: "Media", low: "Baja" }[p] || p);
const getUserId = (u: any) => u?.id || u?.sub || null;
const toggleLabel = (id: string) => {
  const i = taskForm.value.label_ids.indexOf(id);
  i > -1
    ? taskForm.value.label_ids.splice(i, 1)
    : taskForm.value.label_ids.push(id);
};

const renderDescription = (text: string) =>
  text
    ? text.replace(/@(\w+)/g, (m, s) => {
        const d = documents.value.find(
          (d) => d.slug.toLowerCase() === s.toLowerCase()
        );
        return d
          ? `<span class="text-cyan-400 cursor-pointer hover:underline" data-doc-slug="${d.slug}">@${d.slug}</span>`
          : m;
      })
    : "";
const handleDescriptionClick = (e: Event) => {
  const slug = (e.target as HTMLElement).dataset?.docSlug;
  if (slug) {
    const d = documents.value.find(
      (d) => d.slug.toLowerCase() === slug.toLowerCase()
    );
    if (d) openViewDocument(d);
  }
};

const onDescriptionInput = (e: Event) => {
  const t = e.target as HTMLTextAreaElement,
    text = t.value.substring(0, t.selectionStart),
    match = text.match(/@(\w*)$/);
  if (match) {
    autocompleteQuery.value = match[1];
    showAutocomplete.value = true;
    autocompleteIndex.value = 0;
  } else showAutocomplete.value = false;
};
const onDescriptionKeydown = (e: KeyboardEvent) => {
  if (!showAutocomplete.value) return;
  if (e.key === "ArrowDown") {
    e.preventDefault();
    autocompleteIndex.value = Math.min(
      autocompleteIndex.value + 1,
      filteredDocuments.value.length - 1
    );
  } else if (e.key === "ArrowUp") {
    e.preventDefault();
    autocompleteIndex.value = Math.max(autocompleteIndex.value - 1, 0);
  } else if (e.key === "Enter" && filteredDocuments.value.length) {
    e.preventDefault();
    insertDocumentReference(filteredDocuments.value[autocompleteIndex.value]);
  } else if (e.key === "Escape") showAutocomplete.value = false;
};
const insertDocumentReference = (doc: any) => {
  const t = descriptionInput.value;
  if (!t) return;
  const before = taskForm.value.description
      .substring(0, t.selectionStart)
      .replace(/@\w*$/, `@${doc.slug} `),
    after = taskForm.value.description.substring(t.selectionStart);
  taskForm.value.description = before + after;
  showAutocomplete.value = false;
  nextTick(() => {
    t.focus();
    t.selectionStart = t.selectionEnd = before.length;
  });
};

const createNotification = async (
  userId: string,
  type: string,
  title: string,
  message: string,
  link: string
) => {
  await supabase
    .from("notifications")
    .insert({ user_id: userId, type, title, message, link });
};
const onDragChange = async (e: any, statusId: string) => {
  if (e.added) {
    e.added.element.status_id = statusId;
    await supabase
      .from("tasks")
      .update({
        status_id: statusId,
        updated_at: new Date().toISOString(),
      })
      .eq("id", e.added.element.id);
  }
};

const openNewTask = () => {
  editingTask.value = null;
  taskForm.value = {
    title: "",
    description: "",
    status_id: statuses.value[0]?.id || "",
    priority: "medium",
    assignee_ids: [],
    label_ids: [],
  };
  showTaskModal.value = true;
};
const addTaskToColumn = (statusId: string) => {
  editingTask.value = null;
  taskForm.value = {
    title: "",
    description: "",
    status_id: statusId,
    priority: "medium",
    assignee_ids: [],
    label_ids: [],
  };
  showTaskModal.value = true;
};
const openEditTask = (task: any) => {
  editingTask.value = task;
  taskForm.value = {
    title: task.title,
    description: task.description || "",
    status_id: task.status_id,
    priority: task.priority,
    assignee_ids: task.assignees?.map((a: any) => a.user_id) || [],
    label_ids: task.labels?.map((l: any) => l.id) || [],
  };
  showTaskModal.value = true;
};
const closeTaskModal = () => {
  showTaskModal.value = false;
  editingTask.value = null;
  showAutocomplete.value = false;
};

const saveTask = async () => {
  if (!taskForm.value.title.trim()) return;
  const userId = getUserId(user.value);
  const previousAssignees =
    editingTask.value?.assignees?.map((a: any) => a.user_id) || [];

  if (editingTask.value) {
    const { error } = await supabase
      .from("tasks")
      .update({
        title: taskForm.value.title,
        description: taskForm.value.description,
        status_id: taskForm.value.status_id,
        priority: taskForm.value.priority,
        updated_at: new Date().toISOString(),
        updated_by: userId,
      })
      .eq("id", editingTask.value.id);
    if (!error) {
      await supabase
        .from("task_assignees")
        .delete()
        .eq("task_id", editingTask.value.id);
      if (taskForm.value.assignee_ids.length > 0) {
        await supabase.from("task_assignees").insert(
          taskForm.value.assignee_ids.map((uid) => ({
            task_id: editingTask.value.id,
            user_id: uid,
            assigned_by: userId,
          }))
        );
        console.log("Previous Assignees:", previousAssignees);
        for (const id of taskForm.value.assignee_ids.filter(
          (id) => !previousAssignees.includes(id)
        )) {
          if (id !== userId)
            await createNotification(
              id,
              "task_assigned",
              "Nueva tarea asignada",
              `Te han asignado "${taskForm.value.title}"`,
              `/project/${projectId}`
            );
        }
      }
      await supabase
        .from("task_labels")
        .delete()
        .eq("task_id", editingTask.value.id);
      if (taskForm.value.label_ids.length > 0)
        await supabase.from("task_labels").insert(
          taskForm.value.label_ids.map((lid) => ({
            task_id: editingTask.value.id,
            label_id: lid,
          }))
        );
      Object.assign(editingTask.value, {
        title: taskForm.value.title,
        description: taskForm.value.description,
        status_id: taskForm.value.status_id,
        priority: taskForm.value.priority,
        assignees: members.value
          .filter((m) => taskForm.value.assignee_ids.includes(m.user_id))
          .map((m) => ({
            user_id: m.user_id,
            email: m.email,
            full_name: m.full_name,
          })),
        labels: labels.value.filter((l) =>
          taskForm.value.label_ids.includes(l.id)
        ),
      });

      // Actualizar el task en el array de tasks para que la UI refleje los cambios
      const taskIndex = tasks.value.findIndex(
        (t) => t.id === editingTask.value.id
      );
      if (taskIndex > -1) {
        tasks.value[taskIndex] = { ...editingTask.value };
      }
    }
  } else {
    const { data, error } = await supabase
      .from("tasks")
      .insert({
        project_id: projectId,
        title: taskForm.value.title,
        description: taskForm.value.description,
        status_id: taskForm.value.status_id,
        priority: taskForm.value.priority,
        created_by: userId,
        position: tasks.value.length,
      })
      .select()
      .single();
    if (!error && data) {
      if (taskForm.value.assignee_ids.length > 0) {
        await supabase.from("task_assignees").insert(
          taskForm.value.assignee_ids.map((uid) => ({
            task_id: data.id,
            user_id: uid,
            assigned_by: userId,
          }))
        );
        for (const id of taskForm.value.assignee_ids) {
          if (id !== userId)
            await createNotification(
              id,
              "task_assigned",
              "Nueva tarea asignada",
              `Te han asignado "${taskForm.value.title}"`,
              `/project/${projectId}`
            );
        }
      }
      if (taskForm.value.label_ids.length > 0)
        await supabase.from("task_labels").insert(
          taskForm.value.label_ids.map((lid) => ({
            task_id: data.id,
            label_id: lid,
          }))
        );
      data.assignees = members.value
        .filter((m) => taskForm.value.assignee_ids.includes(m.user_id))
        .map((m) => ({
          user_id: m.user_id,
          email: m.email,
          full_name: m.full_name,
        }));
      data.labels = labels.value.filter((l) =>
        taskForm.value.label_ids.includes(l.id)
      );
      tasks.value.push(data);
    }
  }
  closeTaskModal();
};

const deleteTask = async () => {
  if (!editingTask.value) return;
  if (!confirm(`¿Eliminar "${editingTask.value.title}"?`)) return;

  const taskId = editingTask.value.id;

  // Eliminar registros relacionados primero
  await supabase.from("task_activities").delete().eq("task_id", taskId);
  await supabase.from("task_assignees").delete().eq("task_id", taskId);
  await supabase.from("task_labels").delete().eq("task_id", taskId);

  // Ahora eliminar la tarea
  const { error } = await supabase.from("tasks").delete().eq("id", taskId);

  if (error) {
    console.error("Error eliminando tarea:", error);
    alert("Error al eliminar la tarea");
    return;
  }

  tasks.value = tasks.value.filter((t) => t.id !== taskId);
  closeTaskModal();
};

const openNewLabel = () => {
  editingLabel.value = null;
  labelForm.value = { name: "", color: "#6366f1" };
  showAddLabel.value = true;
  sidebarOpen.value = false;
};
const openEditLabel = (label: any, e: Event) => {
  e.stopPropagation();
  editingLabel.value = label;
  labelForm.value = { name: label.name, color: label.color };
  showAddLabel.value = true;
};
const closeLabelModal = () => {
  showAddLabel.value = false;
  editingLabel.value = null;
  labelForm.value = { name: "", color: "#6366f1" };
};

const saveLabel = async () => {
  if (!labelForm.value.name.trim()) return;
  if (editingLabel.value) {
    const { error } = await supabase
      .from("labels")
      .update({ name: labelForm.value.name, color: labelForm.value.color })
      .eq("id", editingLabel.value.id);
    if (!error) {
      Object.assign(editingLabel.value, labelForm.value);
      tasks.value.forEach((t) => {
        const l = t.labels?.find((l: any) => l.id === editingLabel.value.id);
        if (l) {
          l.name = labelForm.value.name;
          l.color = labelForm.value.color;
        }
      });
    }
    const taskIndex = tasks.value.findIndex(
      (t) => t.id === editingTask.value.id
    );
    if (taskIndex > -1) {
      tasks.value[taskIndex] = { ...editingTask.value };
    }
  } else {
    const { data, error } = await supabase
      .from("labels")
      .insert({
        project_id: projectId,
        name: labelForm.value.name,
        color: labelForm.value.color,
      })
      .select()
      .single();
    if (!error && data) labels.value.push(data);
  }
  closeLabelModal();
};

const deleteLabel = async () => {
  if (
    !editingLabel.value ||
    !confirm(`¿Eliminar "${editingLabel.value.name}"?`)
  )
    return;
  await supabase
    .from("task_labels")
    .delete()
    .eq("label_id", editingLabel.value.id);
  await supabase.from("labels").delete().eq("id", editingLabel.value.id);
  labels.value = labels.value.filter((l) => l.id !== editingLabel.value.id);
  tasks.value.forEach((t) => {
    if (t.labels)
      t.labels = t.labels.filter((l: any) => l.id !== editingLabel.value.id);
  });
  if (filterByLabel.value === editingLabel.value.id) filterByLabel.value = null;
  closeLabelModal();
};

const editColumn = (col: any) => {
  editingColumn.value = col;
  columnForm.value = { name: col.name, color: col.color };
  showAddColumn.value = true;
};
const closeColumnModal = () => {
  showAddColumn.value = false;
  editingColumn.value = null;
  columnForm.value = { name: "", color: "#78716c" };
};

const saveColumn = async () => {
  if (!columnForm.value.name.trim()) return;
  if (editingColumn.value) {
    const { error } = await supabase
      .from("task_statuses")
      .update({ name: columnForm.value.name, color: columnForm.value.color })
      .eq("id", editingColumn.value.id);
    if (!error) Object.assign(editingColumn.value, columnForm.value);
  } else {
    const { data, error } = await supabase
      .from("task_statuses")
      .insert({
        project_id: projectId,
        name: columnForm.value.name,
        color: columnForm.value.color,
        position: statuses.value.length,
      })
      .select()
      .single();
    if (!error && data) statuses.value.push(data);
  }
  closeColumnModal();
};

const deleteColumn = async () => {
  if (!editingColumn.value) return;
  if (tasks.value.some((t) => t.status_id === editingColumn.value.id)) {
    alert("Columna tiene tareas");
    return;
  }
  await supabase
    .from("task_statuses")
    .delete()
    .eq("id", editingColumn.value.id);
  statuses.value = statuses.value.filter(
    (s) => s.id !== editingColumn.value.id
  );
  closeColumnModal();
};

const inviteMember = async () => {
  inviteError.value = "";
  inviteSuccess.value = "";
  const { data: profile } = await supabase
    .from("profiles")
    .select("id, email, full_name")
    .eq("email", inviteEmail.value)
    .single();
  if (!profile) {
    inviteError.value = "Usuario no encontrado";
    return;
  }
  if (members.value.find((m) => m.user_id === profile.id)) {
    inviteError.value = "Ya es miembro";
    return;
  }
  const { error } = await supabase.from("workspace_members").insert({
    workspace_id: project.value.workspace_id,
    user_id: profile.id,
    role: "member",
  });
  if (error) {
    inviteError.value = error.message;
    return;
  }
  members.value.push({
    user_id: profile.id,
    email: profile.email,
    full_name: profile.full_name,
    role: "member",
  });
  inviteSuccess.value = "¡Invitado!";
  inviteEmail.value = "";
  setTimeout(() => {
    showInvite.value = false;
    inviteSuccess.value = "";
  }, 1500);
};

const openNewDocument = () => {
  editingDocument.value = null;
  documentForm.value = { title: "", slug: "", content: "" };
  showDocumentModal.value = true;
  sidebarOpen.value = false;
};
const openEditDocument = (doc: any) => {
  editingDocument.value = doc;
  documentForm.value = {
    title: doc.title,
    slug: doc.slug,
    content: doc.content || "",
  };
  showViewDocument.value = false;
  showDocumentModal.value = true;
};
const openViewDocument = (doc: any) => {
  viewingDocument.value = doc;
  showViewDocument.value = true;
  sidebarOpen.value = false;
};
const closeDocumentModal = () => {
  showDocumentModal.value = false;
  editingDocument.value = null;
  documentForm.value = { title: "", slug: "", content: "" };
};
const sanitizeSlug = () => {
  documentForm.value.slug = documentForm.value.slug
    .replace(/[^a-zA-Z0-9_-]/g, "")
    .substring(0, 50);
};

const saveDocument = async () => {
  if (!documentForm.value.title.trim() || !documentForm.value.slug.trim())
    return;
  const userId = getUserId(user.value);
  if (editingDocument.value) {
    const { error } = await supabase
      .from("project_documents")
      .update({
        title: documentForm.value.title,
        slug: documentForm.value.slug,
        content: documentForm.value.content,
        updated_at: new Date().toISOString(),
      })
      .eq("id", editingDocument.value.id);
    if (!error) Object.assign(editingDocument.value, documentForm.value);
  } else {
    const { data, error } = await supabase
      .from("project_documents")
      .insert({
        project_id: projectId,
        title: documentForm.value.title,
        slug: documentForm.value.slug,
        content: documentForm.value.content,
        created_by: userId,
      })
      .select()
      .single();
    if (!error && data) documents.value.push(data);
  }
  closeDocumentModal();
};

const deleteDocument = async () => {
  if (
    !editingDocument.value ||
    !confirm(`¿Eliminar "${editingDocument.value.title}"?`)
  )
    return;
  await supabase
    .from("project_documents")
    .delete()
    .eq("id", editingDocument.value.id);
  documents.value = documents.value.filter(
    (d) => d.id !== editingDocument.value.id
  );
  closeDocumentModal();
};

const copyDocumentContent = async () => {
  if (!viewingDocument.value?.content) return;
  try {
    await navigator.clipboard.writeText(viewingDocument.value.content);
    copied.value = true;
    setTimeout(() => (copied.value = false), 2000);
  } catch (e) {
    console.error(e);
  }
};

const loadProject = async () => {
  const { data } = await supabase
    .from("projects")
    .select("*")
    .eq("id", projectId)
    .single();
  if (data) {
    project.value = data;
    loadMembers(data.workspace_id);
  }
};
const loadStatuses = async () => {
  const { data } = await supabase
    .from("task_statuses")
    .select("*")
    .eq("project_id", projectId)
    .order("position");
  if (data) statuses.value = data;
};
const loadLabels = async () => {
  const { data } = await supabase
    .from("labels")
    .select("*")
    .eq("project_id", projectId)
    .order("created_at");
  if (data) labels.value = data;
};
const loadDocuments = async () => {
  const { data } = await supabase
    .from("project_documents")
    .select("*")
    .eq("project_id", projectId)
    .order("created_at");
  if (data) documents.value = data;
};

const loadTasks = async () => {
  const { data: tasksData } = await supabase
    .from("tasks")
    .select("*")
    .eq("project_id", projectId)
    .order("position");

  if (tasksData?.length) {
    const { data: assigneesData } = await supabase
      .from("task_assignees")
      .select("task_id, user_id, profiles(email, full_name)")
      .in(
        "task_id",
        tasksData.map((t) => t.id)
      );
    const { data: taskLabelsData } = await supabase
      .from("task_labels")
      .select("task_id, label_id, labels(id, name, color)")
      .in(
        "task_id",
        tasksData.map((t) => t.id)
      );
    tasks.value = tasksData.map((task) => ({
      ...task,
      assignees:
        assigneesData
          ?.filter((a) => a.task_id === task.id)
          .map((a) => ({
            user_id: a.user_id,
            email: (a.profiles as any)?.email,
            full_name: (a.profiles as any)?.full_name,
          })) || [],
      labels:
        taskLabelsData
          ?.filter((tl) => tl.task_id === task.id)
          .map((tl) => tl.labels as any) || [],
    }));
  } else tasks.value = [];
};

const openTaskFromActivity = (taskId: string) => {
  const task = tasks.value.find((t) => t.id === taskId);
  if (task) {
    showActivityPanel.value = false;
    oopenEditTask(task);
  }
};

const loadMembers = async (workspaceId: string) => {
  const { data } = await supabase
    .from("workspace_members")
    .select("user_id, role, profiles(email, full_name)")
    .eq("workspace_id", workspaceId);
  if (data)
    members.value = data.map((m: any) => ({
      user_id: m.user_id,
      role: m.role,
      email: m.profiles?.email,
      full_name: m.profiles?.full_name,
    }));
};

onMounted(async () => {
  await loadProject();
  await loadStatuses();
  await loadLabels();
  await loadDocuments();
  await loadTasks();
});
</script>
