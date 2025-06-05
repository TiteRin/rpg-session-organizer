# Guide de Déploiement Railway

Ce document décrit la procédure de déploiement de l'application sur Railway, en incluant les environnements de staging et de production.

## Table des matières
- [Configuration du Projet](#configuration-du-projet)
- [Environnements](#environnements)
- [Configuration Railway](#configuration-railway)
- [Déploiement](#déploiement)
- [Base de données](#base-de-données)
- [Variables d'environnement](#variables-denvironnement)

## Configuration du Projet

### Fichiers de configuration Railway

#### 1. Configuration Backend

##### Script d'Entrée (`backend/entrypoint.sh`)
```bash
#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /app/tmp/pids/server.pid

# Start the Rails server
exec bundle exec rails server -b 0.0.0.0 -p ${PORT:-8080} --log-to-stdout
```

Le script `entrypoint.sh` est un composant crucial du déploiement qui :
- S'exécute à chaque démarrage du conteneur
- Nettoie le fichier `server.pid` pour éviter les conflits de démarrage
- Configure le serveur Rails pour écouter sur toutes les interfaces réseau (`0.0.0.0`)
- Utilise le port fourni par Railway (`PORT`) ou 8080 par défaut
- Redirige les logs vers la sortie standard pour une meilleure visibilité dans Railway

Ce script est référencé dans :
1. Le `Dockerfile.backend` comme point d'entrée du conteneur
2. Le `railway.toml` comme commande de démarrage

##### Dockerfile Backend (`Dockerfile.backend` à la racine)
```dockerfile
FROM ruby:3.3.0

WORKDIR /app

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev

# Install bundler
RUN gem install bundler

# Copy Gemfile and Gemfile.lock
COPY backend/Gemfile backend/Gemfile.lock ./

# Install dependencies
RUN bundle install

# Copy the rest of the backend application
COPY backend/ .

# Add a script to be executed every time the container starts
COPY backend/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# Start the main process
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "${PORT:-8080}", "--log-to-stdout"]
```

##### Dockerfile Frontend (`Dockerfile.frontend` à la racine)
```dockerfile
FROM node:20-alpine

WORKDIR /app

# Copy package files
COPY frontend/package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the frontend application
COPY frontend/ .

# Build the application
RUN npm run build

# Expose the port
EXPOSE 4173

# Start the application
CMD ["npm", "run", "preview", "--", "--host", "0.0.0.0"]
```

##### Configuration Railway (`backend/railway.toml`)
```toml
[phases.setup]
nixPkgs = ["ruby", "bundler"]

[build]
builder = "DOCKERFILE"
dockerfilePath = "Dockerfile"

[deploy]
startCommand = "entrypoint.sh"
healthcheckPath = "/health"
healthcheckTimeout = 100
restartPolicyType = "ON_FAILURE"
restartPolicyMaxRetries = 10

[deploy.env]
RAILS_ENV = "production"
RAILS_LOG_TO_STDOUT = "true"
RAILS_SERVE_STATIC_FILES = "true"
```

#### 2. Configuration Frontend (à configurer après le déploiement du backend)
```toml
[phases.setup]
nixPkgs = ["nodejs", "npm"]

[build]
builder = "nixpacks"
buildCommand = "cd frontend && npm install && npm run build"

[deploy]
startCommand = "cd frontend && npm run preview"
```

### Configuration de la Base de Données

#### 1. Gemfile (`backend/Gemfile`)
```ruby
# Use sqlite3 as the database for Active Record
gem "sqlite3", "~> 1.4"

# Use postgresql as the database for Production
gem "pg", "~> 1.1", group: :production
```

#### 2. Configuration Database (`backend/config/database.yml`)
```yaml
default: &default
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  timeout: 5000

development:
  <<: *default
  adapter: sqlite3
  database: storage/development.sqlite3

test:
  <<: *default
  adapter: sqlite3
  database: storage/test.sqlite3

staging:
  <<: *default
  adapter: postgresql
  url: <%= ENV['DATABASE_URL'] %>
  database: <%= ENV['DATABASE_URL'].split('/').last %>
  encoding: unicode

production:
  <<: *default
  adapter: postgresql
  url: <%= ENV['DATABASE_URL'] %>
  database: <%= ENV['DATABASE_URL'].split('/').last %>
  encoding: unicode
```

## Environnements

### Configuration des Environnements

### 1. Structure des Environnements

Dans Railway, nous configurons deux environnements :

1. **Staging**
   - Branche Git : `staging`
   - URL Backend : `https://backend-staging.up.railway.app`
   - URL Frontend : `https://frontend-staging.up.railway.app`
   - Base de données : `rpg-session-organizer-staging-db`

2. **Production**
   - Branche Git : `main`
   - URL Backend : `https://backend-production.up.railway.app`
   - URL Frontend : `https://frontend-production.up.railway.app`
   - Base de données : `rpg-session-organizer-prod-db`

### 2. Variables d'Environnement

#### Backend

Pour chaque environnement, configurer dans l'interface Railway :

##### Staging
```
RAILS_ENV=staging
RAILS_MASTER_KEY=<valeur_du_master_key>
RAILS_LOG_TO_STDOUT=true
RAILS_SERVE_STATIC_FILES=true
```

##### Production
```
RAILS_ENV=production
RAILS_MASTER_KEY=<valeur_du_master_key>
RAILS_LOG_TO_STDOUT=true
RAILS_SERVE_STATIC_FILES=true
```

#### Frontend

Pour chaque environnement, configurer dans l'interface Railway :

##### Staging
```
VITE_API_URL=https://backend-staging.up.railway.app
```

##### Production
```
VITE_API_URL=https://backend-production.up.railway.app
```

### 3. Workflow de Déploiement

1. **Développement**
   - Travailler sur des branches feature
   - Utiliser SQLite en local
   - Tester avec `npm run dev` (frontend) et `rails s` (backend)

2. **Staging**
   - Merger les features dans la branche `staging`
   - Déploiement automatique sur l'environnement de staging
   - Tests et validation
   - URL : `https://frontend-staging.up.railway.app`

3. **Production**
   - Merger `staging` dans `main`
   - Déploiement automatique sur l'environnement de production
   - URL : `https://frontend-production.up.railway.app`

> **Note** : 
> - Les variables d'environnement sont configurées dans l'interface Railway pour chaque service
> - Les URLs des services sont automatiquement générées par Railway
> - La variable `DATABASE_URL` est automatiquement configurée par Railway
> - Les credentials Rails sont différents pour chaque environnement

## Configuration Railway

### 1. Configuration du Projet

#### Option 1 : Projet Existant (Recommandé)
1. Dans votre projet Railway existant, créer deux services séparés :
   - Un service pour le backend
   - Un service pour le frontend

2. Pour le backend :
   - Sélectionner "Deploy from GitHub repo"
   - Choisir le repository
   - Dans les paramètres du service :
     - Root Directory: `backend`
     - Dockerfile Path: `Dockerfile`
   - Railway va automatiquement détecter et utiliser `backend/railway.toml`

3. Pour le frontend :
   - Sélectionner "Deploy from GitHub repo"
   - Choisir le même repository
   - Dans les paramètres du service :
     - Root Directory: `frontend`
     - Dockerfile Path: `Dockerfile`
   - Railway va automatiquement détecter et utiliser `frontend/railway.toml`

#### Option 2 : Nouveau Projet
1. Aller sur [Railway](https://railway.app)
2. Cliquer sur "New Project"
3. Suivre les étapes 2 et 3 de l'Option 1 pour chaque service

> **Important** : 
> - Chaque service doit être configuré séparément dans l'interface Railway
> - Chaque service a son propre fichier `railway.toml` dans son répertoire
> - Les variables d'environnement spécifiques à chaque service sont configurées dans l'interface Railway

### 2. Configuration des Services

#### Backend (`backend/railway.toml`)
```toml
[phases.setup]
nixPkgs = ["ruby", "bundler"]

[build]
builder = "DOCKERFILE"
dockerfilePath = "backend/Dockerfile"
buildContext = "backend"

[deploy]
startCommand = "entrypoint.sh"
restartPolicyType = "ON_FAILURE"
restartPolicyMaxRetries = 10
```

#### Frontend (`frontend/railway.toml`)
```toml
[phases.setup]
nixPkgs = ["nodejs", "npm"]

[build]
builder = "DOCKERFILE"
dockerfilePath = "frontend/Dockerfile"
buildContext = "frontend"

[deploy]
restartPolicyType = "ON_FAILURE"
restartPolicyMaxRetries = 10
```

> **Note** : 
> - Les Dockerfiles sont placés dans leurs répertoires respectifs (`backend/Dockerfile` et `frontend/Dockerfile`)
> - Les chemins dans les Dockerfiles sont relatifs au contexte de build spécifié dans `railway.toml`
> - Le `buildContext` dans `railway.toml` indique le répertoire à partir duquel les fichiers seront copiés
> - Les variables d'environnement doivent être configurées dans l'interface Railway pour une meilleure sécurité et flexibilité
> - Chaque service a sa propre configuration dans son répertoire pour une meilleure organisation et maintenance

## Variables d'environnement

### Template des Variables d'Environnement

Des fichiers de template sont fournis dans le dossier `backend/` pour servir de référence pour les variables d'environnement nécessaires. Ces fichiers ne contiennent pas de valeurs sensibles mais documentent toutes les variables requises pour chaque environnement.

#### Développement Local (`.env.example`)
```bash
# Rails Environment
RAILS_ENV=development
RAILS_MASTER_KEY=your_master_key_here

# Database Configuration
DATABASE_URL=postgresql://localhost/rpg_session_organizer_development

# Server Configuration
RAILS_MAX_THREADS=5
PORT=3000

# Logging
RAILS_LOG_LEVEL=debug

# Frontend API URL (for development)
VITE_API_URL=http://localhost:3000

# Add your custom environment variables below
# MY_CUSTOM_VAR=value
```

#### Staging (`.env.staging.example`)
```bash
# Rails Environment
RAILS_ENV=staging
RAILS_MASTER_KEY=your_master_key_here

# Database Configuration
# DATABASE_URL is automatically set by Railway

# Server Configuration
RAILS_MAX_THREADS=5
PORT=8080

# Logging
RAILS_LOG_LEVEL=info

# Frontend API URL
VITE_API_URL=https://rpg-session-organizer-staging-backend.up.railway.app

# Add your custom environment variables below
# MY_CUSTOM_VAR=value
```

#### Production (`.env.production.example`)
```bash
# Rails Environment
RAILS_ENV=production
RAILS_MASTER_KEY=your_master_key_here

# Database Configuration
# DATABASE_URL is automatically set by Railway

# Server Configuration
RAILS_MAX_THREADS=5
PORT=8080

# Logging
RAILS_LOG_LEVEL=info

# Frontend API URL
VITE_API_URL=https://rpg-session-organizer-prod-backend.up.railway.app

# Add your custom environment variables below
# MY_CUSTOM_VAR=value
```

Pour utiliser ces templates :
1. Copier le fichier approprié vers `.env` : 
   ```bash
   # Pour le développement local
   cp backend/.env.example backend/.env
   
   # Pour le staging
   cp backend/.env.staging.example backend/.env.staging
   
   # Pour la production
   cp backend/.env.production.example backend/.env.production
   ```
2. Remplir les valeurs appropriées dans le fichier copié
3. Ne jamais commiter les fichiers `.env*` dans le dépôt Git

> **Note** : 
> - Les fichiers `.env*` sont déjà dans `.gitignore` pour éviter tout commit accidentel
> - Les fichiers de template (`.env*.example`) doivent être commités dans le dépôt
> - La variable `DATABASE_URL` est automatiquement configurée par Railway pour les environnements de staging et production

### Backend

Pour chaque environnement, configurer :

#### Staging
```
RAILS_ENV=staging
RAILS_MASTER_KEY=<valeur_du_master_key>
```

#### Production
```
RAILS_ENV=production
RAILS_MASTER_KEY=<valeur_du_master_key>
```

> **Note** : 
> - La variable `DATABASE_URL` est automatiquement configurée par Railway lors de la création de la base de données PostgreSQL. Il n'est pas nécessaire de la définir manuellement.
> - La variable `RAILS_MASTER_KEY` doit être la même que celle utilisée localement pour chiffrer/déchiffrer les credentials. Vous pouvez la trouver dans le fichier `backend/config/master.key`.

### Frontend

Pour chaque environnement, configurer :

#### Staging
```