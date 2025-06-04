<template>
    <ul class="timeline timeline-vertical">
        <li v-for="session in sessions" :key="session.id">
            <SessionItem :session="session" />
        </li>
    </ul>
</template>

<script setup lang="ts">
import SessionItem from '@/components/sessions/SessionItem.vue'

defineProps({
    sessions: {
        type: Array,
        required: true
    }
})
</script>