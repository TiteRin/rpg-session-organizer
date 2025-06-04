
# Architecture technique - RPG Session Organizer

## Backend

- **Framework** : Ruby on Rails (API mode)  
- **Langage** : Ruby 3.x  
- **Base de données** : PostgreSQL (prod) / SQLite (dev)  
- **ORM** : ActiveRecord  
- **API** : REST JSON  
- **Modèles** : Session, Player, Attendance  
- **Authentification** : à prévoir (optionnel)  
- **Tests** : RSpec (optionnel)  

## Frontend

- **Framework** : Vue.js 3 (Composition API)  
- **API Calls** : Axios  
- **Gestion d’état** : `ref`, `reactive`, `computed`  
- **Build tool** : Vite  
- **Routing** : Vue Router (optionnel)  
- **Styling** : CSS Modules ou TailwindCSS (optionnel)  

## Communication

- Frontend interroge backend via API REST  
- CORS configuré sur backend pour autoriser frontend  

## Déploiement

- Backend : Heroku, Render, ou autre  
- Frontend : Vercel, Netlify, ou autre  