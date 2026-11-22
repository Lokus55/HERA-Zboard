<script setup lang="ts">
const { language } = useInterfaceLanguage()
useHead(() => ({ htmlAttrs: { lang: language.value } }))
</script>

<template>
  <NuxtLayout>
    <NuxtPage />
  </NuxtLayout>
</template>
