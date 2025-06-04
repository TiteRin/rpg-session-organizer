import { createRouter, createWebHistory } from 'vue-router'
import Sessions from '../views/Sessions.vue'

const routes = [
  {
    path: '/',
    redirect: '/sessions'
  },
  {
    path: '/sessions',
    name: 'Sessions',
    component: Sessions
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router 