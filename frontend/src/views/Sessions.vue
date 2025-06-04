<template>
  <div class="p-4">
    <h1 class="text-2xl font-bold mb-4">Sessions de JdR</h1>
    <ul>
      <li v-for="session in sessions" :key="session.id" class="mb-2 p-4 bg-base-200 rounded">
        <h2 class="text-lg font-semibold">{{ session.title }}</h2>
        <p>Prévue le : {{ new Date(session.scheduled_at).toLocaleString() }}</p>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const sessions = ref([])

onMounted(async () => {
  const res = await fetch('http://localhost:3000/api/sessions')
  sessions.value = await res.json()
})
</script>
