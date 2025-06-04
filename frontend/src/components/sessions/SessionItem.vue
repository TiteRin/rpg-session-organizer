<template>
    <hr :class="{'bg-primary': isDone()}" />
    <div class="timeline-start timeline-box text-xs my-4 mr-2">
        {{ formatDate(session.scheduled_at) }}
    </div>

    <div :class="{'text-primary': isDone(), 'text-gray-500': !isDone()}" class="timeline-middle my-1">
        <CircleCheckBig size="20" strokeWidth="2" v-if="isDone()" />
        <CalendarDays :size="20" strokeWidth="2" v-else-if="isToday()" />
        <Circle size="20" strokeWidth="2" v-else/>
    </div>

    <div class="timeline-end my-4 ml-2" @click="onClick">
        {{ session.title }}
    </div>
    <hr :class="{'bg-primary': isDone()}" />
</template>

<script setup lang="ts">
import type { Session } from '@/types/session'
import { CircleCheckBig, CalendarDays, Circle } from 'lucide-vue-next';


interface Props {
    session: Session
}

const props = defineProps<Props>()
const emit = defineEmits<{
    'select-session': [session: Session]
}>()

const formatDate = (date: string): string => {
    return new Date(date).toLocaleString()
}

const isDone = (): boolean => props.session.scheduled_at < new Date().toISOString();
const isToday = (): boolean => new Date(props.session.scheduled_at).toDateString() === new Date().toDateString();

const onClick = (): void => {
    emit('select-session', props.session)
}
</script>