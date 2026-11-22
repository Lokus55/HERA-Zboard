<script setup lang="ts">
const { language, setLanguage, t } = useInterfaceLanguage()

function changeLanguage(event: Event) {
  setLanguage((event.target as HTMLSelectElement).value)
}
</script>

<template>
  <select
    :value="language"
    :aria-label="t('language')"
    class="max-w-full rounded-md border border-neutral-700 bg-neutral-900 px-2 py-1 text-sm text-neutral-200 focus-visible:outline focus-visible:outline-2 focus-visible:outline-cyan-400"
    @change="changeLanguage"
  >
    <option value="en" lang="en">English</option>
    <option value="es" lang="es">Español</option>
  </select>
</template>
