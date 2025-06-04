# RPG Session Organizer

Application web pour aider le Maître de Jeu (MJ) et les joueurs à organiser leurs sessions de jeu de rôle.

## Description

Permet au MJ de proposer une date de session, aux joueurs de confirmer leur présence et d'indiquer ce qu'ils apportent (snacks, boissons). On peut aussi consulter le nom de la prochaine session et un récapitulatif de la session précédente.

## Fonctionnalités

- Proposer/modifier la session à venir (date, nom, récapitulatif)  
- Les joueurs confirment leur présence (oui/non)  
- Les joueurs ajoutent ce qu'ils apportent  
- Visualiser la session suivante et le résumé de la session passée  

## Installation

### Backend

```bash
cd backend
bundle install
rails db:create db:migrate
rails server
```

### Frontend

```bash
cd frontend
yarn install
yarn dev
```

## Installation avec Docker

Le projet peut être démarré facilement avec Docker Compose :

```bash
# Construire et démarrer les conteneurs
docker compose up --build

# Pour arrêter les conteneurs
docker compose down
```

Les services seront disponibles aux adresses suivantes :
- Frontend : http://localhost:5173
- Backend : http://localhost:3000

### Commandes Docker utiles

```bash
# Voir les logs des conteneurs
docker compose logs -f

# Voir les logs d'un service spécifique
docker compose logs -f backend
docker compose logs -f frontend

# Exécuter une commande Rails dans le conteneur backend
docker compose exec backend bundle exec rails <commande>

# Exécuter une commande dans le conteneur frontend
docker compose exec frontend <commande>
```

## Architecture

* Backend : API REST Rails (models Session, Player, Attendance)
* Frontend : Vue 3 Composition API avec Axios

## Usage

1. Le MJ crée ou modifie la session à venir
2. Les joueurs indiquent leur présence et ce qu'ils apportent
3. Tous peuvent consulter le récapitulatif de la session précédente

---

## Licence

MIT