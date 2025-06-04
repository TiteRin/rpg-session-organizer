<template>
  <div class="p-4">
    <h1 class="text-2xl font-bold mb-4">Sessions de JdR</h1>
    <SessionList :sessions="sessions" />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import SessionList from '@/components/sessions/SessionList.vue'

const sessions = ref([])

onMounted(async () => {
  const res = await fetch('http://localhost:3000/api/sessions')
  sessions.value = await res.json()
})
</script>
