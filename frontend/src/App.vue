<script setup>
// No additional imports needed
</script>

<template>
  <div class="min-h-screen bg-base-100">
    <nav class="navbar bg-base-200">
      <div class="container mx-auto">
        <a class="btn btn-ghost text-xl">RPG Session Organizer</a>
      </div>
    </nav>
    <main class="container mx-auto py-4">
      <router-view></router-view>
    </main>
  </div>
</template>

<style>
/* Global styles are in style.css */
</style>
