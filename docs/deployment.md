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

##### Dockerfile (`backend/Dockerfile`)
```dockerfile
FROM ruby:3.3.0

WORKDIR /app

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev

# Install bundler
RUN gem install bundler

# Copy Gemfile and Gemfile.lock from the backend directory
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
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
```

##### Script d'entrée (`backend/entrypoint.sh`)
```bash
#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /app/tmp/pids/server.pid

# Then exec the container's main process
exec "$@"
```

##### Configuration Railway (`railway.toml`)
```toml
[build]
builder = "DOCKERFILE"
dockerfilePath = "backend/Dockerfile"

[deploy]
startCommand = "bundle exec rails server -b 0.0.0.0"
healthcheckPath = "/api/health"
healthcheckTimeout = 100
```

> **Note** : Cette configuration utilise un Dockerfile explicite pour s'assurer que toutes les dépendances sont correctement installées et configurées.

#### 2. Configuration Frontend (à configurer après le déploiement du backend)
```toml
[phases.setup]
nixPkgs = ["nodejs", "npm"]

[build]
builder = "nixpacks"
buildCommand = "cd frontend && npm install && npm run build"

[deploy]
startCommand = "cd frontend && npm run preview"
healthcheckPath = "/"
healthcheckTimeout = 100
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

### 1. Création du Projet

1. Aller sur [Railway](https://railway.app)
2. Cliquer sur "New Project"
3. Sélectionner "Deploy from GitHub repo"
4. Choisir le repository

### 2. Configuration des Environnements

1. Dans le projet Railway, aller dans "Settings" > "Environments"
2. Créer deux environnements :
   - `staging`
   - `production`
3. Pour chaque environnement :
   - Configurer les variables d'environnement spécifiques
   - Créer une base de données PostgreSQL dédiée

### 3. Configuration des Déploiements

1. Dans "Settings" > "Git"
2. Configurer les déploiements automatiques :
   - Pour l'environnement staging :
     - Branche : `staging`
     - Environnement : `staging`
   - Pour l'environnement production :
     - Branche : `main`
     - Environnement : `production`

### 4. Configuration des Bases de Données

Pour chaque environnement :

1. Dans l'onglet de l'environnement, cliquer sur "New"
2. Sélectionner "Database" > "PostgreSQL"
3. Railway créera automatiquement :
   - Une base de données PostgreSQL
   - La variable d'environnement `DATABASE_URL` spécifique à l'environnement

## Variables d'environnement

### Backend

Pour chaque environnement, configurer uniquement :

#### Staging
```
RAILS_ENV=staging
```

#### Production
```
RAILS_ENV=production
```

> **Note** : La variable `DATABASE_URL` est automatiquement configurée par Railway lors de la création de la base de données PostgreSQL. Il n'est pas nécessaire de la définir manuellement.

### Frontend

Pour chaque environnement, configurer :

#### Staging
```
VITE_API_URL=https://rpg-session-organizer-staging-backend.up.railway.app
```

#### Production
```
VITE_API_URL=https://rpg-session-organizer-prod-backend.up.railway.app
```

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

### Healthcheck

Le healthcheck est un mécanisme utilisé par Railway pour vérifier que votre application est correctement démarrée et fonctionnelle. Par défaut, il essaie d'accéder à l'URL racine ("/") de votre application.

#### Configuration du Healthcheck

1. **Endpoint de Healthcheck**
   - Un endpoint dédié est configuré à `/api/health`
   - Il renvoie un statut 200 avec `{ status: 'ok' }`
   - Cet endpoint est utilisé par Railway pour vérifier l'état de l'application

2. **Configuration Railway**
   ```toml
   [deploy]
   healthcheckPath = "/api/health"
   healthcheckTimeout = 100
   ```

3. **Dépannage du Healthcheck**
   - Si le healthcheck échoue, vérifiez que :
     - Le serveur Rails écoute sur le port fourni par Railway (`ENV['PORT']`)
     - L'endpoint `/api/health` est accessible
     - Les logs de l'application pour identifier d'éventuelles erreurs

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