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

##### Configuration Railway (`railway.toml`)
```toml
[phases.setup]
nixPkgs = ["ruby", "bundler", "nodejs", "npm"]

[build]
builder = "DOCKERFILE"
dockerfilePath = "Dockerfile.backend"

[deploy]
startCommand = "entrypoint.sh"

[deploy.services]
backend = { 
  path = "backend",
  dockerfilePath = "Dockerfile.backend",
  env = {
    RAILS_ENV = "production",
    RAILS_LOG_TO_STDOUT = "true",
    RAILS_SERVE_STATIC_FILES = "true"
  }
}
frontend = { 
  path = "frontend",
  dockerfilePath = "Dockerfile.frontend",
  env = { 
    VITE_API_URL = "https://rpg-session-organizer-staging.up.railway.app"
  }
}
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

### Structure des Environnements Railway

Dans un même projet Railway, nous configurons deux environnements :

1. **Staging**
   - Branche Git : `staging`
   - URL : `https://rpg-session-organizer-staging.up.railway.app`
   - Base de données : `rpg-session-organizer-staging-db`

2. **Production**
   - Branche Git : `main`
   - URL : `https://rpg-session-organizer-prod.up.railway.app`
   - Base de données : `rpg-session-organizer-prod-db`

## Configuration Railway

### 1. Configuration du Projet

#### Option 1 : Projet Existant (Recommandé)
1. Dans votre projet Railway existant, cliquer sur "New Service"
2. Sélectionner "Deploy from GitHub repo"
3. Choisir le même repository
4. Railway va automatiquement :
   - Détecter le fichier `railway.toml`
   - Créer les deux services (backend et frontend) définis dans ce fichier
   - Configurer chaque service selon les paramètres spécifiés

#### Option 2 : Nouveau Projet
1. Aller sur [Railway](https://railway.app)
2. Cliquer sur "New Project"
3. Sélectionner "Deploy from GitHub repo"
4. Choisir le repository
5. Railway va automatiquement :
   - Détecter le fichier `railway.toml`
   - Créer les deux services (backend et frontend) définis dans ce fichier
   - Configurer chaque service selon les paramètres spécifiés

> **Important** : 
> - Vous n'avez pas besoin de créer manuellement les services dans l'interface Railway
> - Les services sont créés automatiquement en fonction du `railway.toml`
> - Si vous utilisez l'Option 2, assurez-vous de recréer la base de données

### 2. Gestion de la Base de Données

> **Important** : Si vous recréez le projet :
> - Ne supprimez PAS la base de données PostgreSQL existante
> - La variable `DATABASE_URL` sera automatiquement configurée
> - Vous pouvez supprimer l'ancien service, il sera recréé avec la bonne configuration

Pour configurer la base de données :
1. Dans le projet Railway, cliquer sur "New"
2. Sélectionner "Database" > "PostgreSQL"
3. Railway va :
   - Créer une nouvelle base de données
   - Configurer automatiquement la variable `DATABASE_URL`
   - Fournir les informations de connexion

### 3. Configuration Multi-Services

Notre application utilise une architecture multi-services, configurée via le fichier `railway.toml`. Ce fichier définit deux services qui seront automatiquement créés par Railway :

#### Configuration dans railway.toml
```toml
[phases.setup]
nixPkgs = ["ruby", "bundler", "nodejs", "npm"]

[build]
builder = "DOCKERFILE"
dockerfilePath = "Dockerfile.backend"

[deploy]
startCommand = "entrypoint.sh"

[deploy.services]
backend = { 
  path = "backend",
  dockerfilePath = "Dockerfile.backend",
  env = {
    RAILS_ENV = "production",
    RAILS_LOG_TO_STDOUT = "true",
    RAILS_SERVE_STATIC_FILES = "true"
  }
}
frontend = { 
  path = "frontend",
  dockerfilePath = "Dockerfile.frontend",
  env = { 
    VITE_API_URL = "https://rpg-session-organizer-staging.up.railway.app"
  }
}
```

Cette configuration :
- Définit les deux services (backend et frontend)
- Spécifie le chemin et le Dockerfile pour chaque service
- Configure les variables d'environnement nécessaires

#### Service Backend (Rails)
- **Path** : `backend/`
- **Dockerfile** : `Dockerfile.backend`
- **Variables d'environnement requises** :
  ```
  RAILS_ENV=production
  RAILS_MASTER_KEY=<valeur_du_master_key>
  DATABASE_URL=<fourni par Railway>
  RAILS_LOG_TO_STDOUT=true
  RAILS_SERVE_STATIC_FILES=true
  ```

#### Service Frontend (Vue.js)
- **Path** : `frontend/`
- **Dockerfile** : `Dockerfile.frontend`
- **Variables d'environnement requises** :
  ```
  VITE_API_URL=<url_du_backend>
  ```

### 4. Fichiers de Configuration

#### Dockerfile.frontend
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

### 5. URLs des Services

Une fois déployés, chaque service aura sa propre URL :
- Backend : `https://rpg-session-organizer-staging.up.railway.app`
- Frontend : Une URL différente fournie par Railway

> **Note** : 
> - Les services sont créés automatiquement par Railway en fonction du `railway.toml`
> - Chaque service a ses propres logs et métriques
> - Les services peuvent être redémarrés ou mis à l'échelle séparément
> - Le frontend doit pointer vers l'URL du backend via la variable `VITE_API_URL`

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
VITE_API_URL=https://rpg-session-organizer-staging.up.railway.app
```

#### Production
```
VITE_API_URL=https://rpg-session-organizer-prod.up.railway.app
```

## Configuration des Credentials

### Génération des Credentials

Pour chaque environnement (staging et production), il est nécessaire de générer des credentials :

```bash
# Pour l'environnement de staging
RAILS_ENV=staging bin/rails credentials:edit

# Pour l'environnement de production
RAILS_ENV=production bin/rails credentials:edit
```

### Structure des Credentials

Les credentials sont stockés dans des fichiers chiffrés :
- Staging : `backend/config/credentials/staging.yml.enc`
- Production : `backend/config/credentials/production.yml.enc`

Ces fichiers sont chiffrés avec la clé maître stockée dans `backend/config/master.key`.

### Sécurité

> **Important** :
> - Ne jamais commiter le fichier `master.key` dans le dépôt Git
> - Ne jamais exposer la valeur de `RAILS_MASTER_KEY` publiquement
> - Utiliser des valeurs différentes pour les credentials de staging et de production
> - Stocker la valeur de `RAILS_MASTER_KEY` de manière sécurisée dans Railway

## Déploiement

### Workflow de Déploiement

1. **Développement**
   - Travailler sur des branches feature
   - Utiliser SQLite en local

2. **Staging**
   - Merger les features dans la branche `staging`
   - Déploiement automatique sur l'environnement de staging
   - Tests et validation

3. **Production**
   - Merger `staging` dans `main`
   - Déploiement automatique sur l'environnement de production

### Commandes Utiles

```bash
# Vérifier les migrations en attente
rails db:migrate:status

# Exécuter les migrations
rails db:migrate

# Vérifier les logs de déploiement
railway logs
```

## Maintenance

### Surveillance

- Utiliser le dashboard Railway pour surveiller :
  - L'utilisation des ressources
  - Les logs
  - L'état des services

### Sauvegardes

- Les bases de données PostgreSQL sont automatiquement sauvegardées par Railway
- Les sauvegardes sont conservées pendant 7 jours

### Mise à l'échelle

- Railway permet de mettre à l'échelle automatiquement les services
- Configurer les limites dans les paramètres du projet

## Dépannage

### Problèmes Courants

1. **Échec de déploiement**
   - Vérifier les logs de build
   - S'assurer que toutes les variables d'environnement sont configurées

2. **Problèmes de base de données**
   - Vérifier la connexion avec `rails dbconsole`
   - Vérifier les migrations avec `rails db:migrate:status`

3. **Problèmes de CORS**
   - Vérifier la configuration CORS dans le backend
   - Vérifier les URLs dans les variables d'environnement du frontend 