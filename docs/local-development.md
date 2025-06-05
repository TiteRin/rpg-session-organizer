# Guide de Développement Local

Ce document explique comment configurer et exécuter l'application en local pour le développement.

## Prérequis

- Ruby 3.3.0
- Node.js 20+
- SQLite3 (pour le développement)
- PostgreSQL (pour la production)
- Bundler
- npm
- Docker et Docker Compose (optionnel)

## Configuration

### Option 1 : Docker Compose (Recommandé)

Cette option permet de lancer tous les services (backend et frontend) en une seule commande.

1. Créer un fichier `.env` à la racine du projet :
```bash
RAILS_MASTER_KEY=votre_clé_master
```

2. Lancer les services :
```bash
docker compose up
```

Les services seront accessibles sur :
- Backend : `http://localhost:3000`
- Frontend : `http://localhost:5173`

> **Note** : En développement, l'application utilise SQLite comme base de données. La base de données sera créée automatiquement dans le dossier `backend/db/`.

### Option 2 : Installation Manuelle

#### 1. Backend (Rails)

#### Configuration de l'environnement
1. Créer un fichier `.env` dans le dossier `backend/` :
```bash
# Rails Environment
RAILS_ENV=development
RAILS_MASTER_KEY=votre_clé_master

# Server Configuration
RAILS_MAX_THREADS=5
PORT=3000

# Logging
RAILS_LOG_LEVEL=debug
```

#### Installation et démarrage
```bash
cd backend
bundle install
rails db:create db:migrate
rails server
```

Le backend sera accessible sur `http://localhost:3000`

### 2. Frontend (Vue.js)

#### Configuration de l'environnement
1. Créer un fichier `.env` dans le dossier `frontend/` :
```bash
VITE_API_URL=http://localhost:3000
```

#### Installation et démarrage
```bash
cd frontend
npm install
npm run dev
```

Le frontend sera accessible sur `http://localhost:5173`

## Vérification

1. Ouvrir `http://localhost:5173` dans votre navigateur
2. Vérifier que l'application se charge correctement
3. Vérifier que les appels API vers le backend fonctionnent

## Commandes utiles

```bash
# Docker Compose
docker compose up              # Démarrer tous les services
docker compose up -d          # Démarrer en arrière-plan
docker compose down           # Arrêter tous les services
docker compose logs -f        # Voir les logs en temps réel
docker compose ps             # Voir l'état des services

# Backend
rails routes          # Lister les routes disponibles
rails console        # Ouvrir la console Rails
rails db:migrate     # Exécuter les migrations
rails test          # Lancer les tests

# Frontend
npm run build       # Construire pour la production
npm run test       # Lancer les tests
npm run lint       # Vérifier le code
```

## Dépannage

### Problèmes courants

1. **Erreur de base de données**
   - Vérifier que le fichier `development.sqlite3` existe dans `backend/db/`
   - Si nécessaire, recréer la base de données :
     ```bash
     rails db:drop db:create db:migrate
     ```

2. **Erreur CORS**
   - Vérifier que le backend est bien en cours d'exécution sur le port 3000
   - Vérifier que `VITE_API_URL` pointe vers la bonne URL

3. **Erreur de dépendances**
   - Supprimer `node_modules` et `package-lock.json` puis relancer `npm install`
   - Supprimer `Gemfile.lock` et relancer `bundle install`
   - Si vous utilisez Docker Compose, reconstruire les images :
     ```bash
     docker compose build --no-cache
     ```

4. **Problèmes avec Docker Compose**
   - Vérifier que tous les ports nécessaires sont disponibles
   - Vérifier que les volumes sont correctement montés
   - Nettoyer les conteneurs et volumes si nécessaire :
     ```bash
     docker compose down -v
     ``` 