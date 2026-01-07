<template>
  <div class="min-h-screen flex flex-col">
    <nav class="border-b border-neutral-800 bg-neutral-950/80 sticky top-0 z-50">
      <div class="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
        <div class="flex items-center gap-3">
          <div class="w-9 h-9 rounded-xl bg-gradient-to-br from-cyan-400 to-cyan-600 flex items-center justify-center">
            <span class="text-neutral-950 font-bold">Z</span>
          </div>
          <span class="font-bold text-xl">Zboard</span>
        </div>
        <div class="flex items-center gap-4">
          <NuxtLink to="/auth/login" class="btn-ghost">Iniciar sesión</NuxtLink>
          <NuxtLink to="/auth/register" class="btn-primary">Comenzar gratis</NuxtLink>
        </div>
      </div>
    </nav>

    <main class="flex-1 flex items-center justify-center">
      <div class="text-center max-w-4xl mx-auto px-6">
        <h1 class="text-5xl lg:text-7xl font-bold mb-6">
          Gestiona proyectos
          <span class="text-cyan-400">sin límites</span>
        </h1>
        <!-- <p class="text-xl text-neutral-400 mb-10">
          La alternativa open-source a Notion y Jira.
        </p> -->
        <NuxtLink to="/auth/register" class="btn-primary text-lg px-8 py-3">
          Empezar ahora →
        </NuxtLink>
      </div>
    </main>
  </div>
</template>
