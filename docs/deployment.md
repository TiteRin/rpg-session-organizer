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

#### 1. Configuration racine (`railway.toml`)
```toml
[build]
builder = "nixpacks"
buildCommand = "echo 'No build command needed for monorepo'"

[deploy]
startCommand = "echo 'No start command needed for monorepo'"
healthcheckPath = "/"
healthcheckTimeout = 100
restartPolicyType = "on-failure"
restartPolicyMaxRetries = 10

[deploy.services]
backend = { path = "backend" }
frontend = { path = "frontend" }
```

#### 2. Configuration Backend (`backend/railway.toml`)
```toml
[build]
builder = "nixpacks"
buildCommand = "bundle install"

[deploy]
startCommand = "bundle exec rails server -b 0.0.0.0"
healthcheckPath = "/"
healthcheckTimeout = 100
restartPolicyType = "on-failure"
restartPolicyMaxRetries = 10
```

#### 3. Configuration Frontend (`frontend/railway.toml`)
```toml
[build]
builder = "nixpacks"
buildCommand = "npm install && npm run build"

[deploy]
startCommand = "npm run preview"
healthcheckPath = "/"
healthcheckTimeout = 100
restartPolicyType = "on-failure"
restartPolicyMaxRetries = 10
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

Pour chaque environnement, configurer :

#### Staging
```
RAILS_ENV=staging
DATABASE_URL=<url-staging>
```

#### Production
```
RAILS_ENV=production
DATABASE_URL=<url-production>
```

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