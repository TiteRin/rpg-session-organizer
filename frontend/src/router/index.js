import { createRouter, createWebHistory } from 'vue-router'
import Sessions from '../views/Sessions.vue'
import SessionDetail from '../views/SessionDetail.vue'

const routes = [
  {
    path: '/',
  },
  {
    path: '/sessions',
    name: 'Sessions',
    component: Sessions
  },
  {
    path: '/sessions/:id',
    name: 'SessionDetail',
    component: SessionDetail
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router 