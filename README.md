# RPG Session Organizer

Application web pour aider le Maître de Jeu (MJ) et les joueurs à organiser leurs sessions de jeu de rôle.

## Description

Permet au MJ de proposer une date de session, aux joueurs de confirmer leur présence et d’indiquer ce qu’ils apportent (snacks, boissons). On peut aussi consulter le nom de la prochaine session et un récapitulatif de la session précédente.

## Fonctionnalités

- Proposer/modifier la session à venir (date, nom, récapitulatif)  
- Les joueurs confirment leur présence (oui/non)  
- Les joueurs ajoutent ce qu’ils apportent  
- Visualiser la session suivante et le résumé de la session passée  

## Installation

### Backend

```bash
cd backend
bundle install
rails db:create db:migrate
rails server
````

### Frontend

```bash
cd frontend
npm install
npm run dev
```

## Architecture

* Backend : API REST Rails (models Session, Player, Attendance)
* Frontend : Vue 3 Composition API avec Axios

## Usage

1. Le MJ crée ou modifie la session à venir
2. Les joueurs indiquent leur présence et ce qu’ils apportent
3. Tous peuvent consulter le récapitulatif de la session précédente

---

## Licence

MIT