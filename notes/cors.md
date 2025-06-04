# Guide des Erreurs CORS (Cross-Origin Resource Sharing)

## Qu'est-ce que CORS ?

CORS (Cross-Origin Resource Sharing) est un mécanisme de sécurité implémenté par les navigateurs web qui contrôle comment les ressources web d'une origine (domaine, protocole ou port) peuvent être demandées depuis une autre origine.

## Pourquoi les erreurs CORS se produisent-elles ?

Les erreurs CORS se produisent lorsque :
1. Votre frontend (ex: `http://localhost:5173`) essaie d'accéder à une API sur une origine différente (ex: `http://localhost:3000`)
2. Le serveur backend n'a pas configuré les en-têtes CORS appropriés pour autoriser ces requêtes
3. Les navigateurs bloquent ces requêtes par défaut pour des raisons de sécurité

## Comment prévenir/corriger les erreurs CORS

### Solution Générale

1. **Configuration du Backend**
   - Ajouter les en-têtes CORS appropriés
   - Spécifier les origines autorisées
   - Configurer les méthodes HTTP autorisées
   - Gérer les credentials si nécessaire

2. **Bonnes Pratiques**
   - Limiter les origines autorisées aux domaines nécessaires
   - Utiliser HTTPS en production
   - Configurer correctement les credentials si nécessaire

### Dans notre contexte Rails/Vue

#### Configuration Rails

1. **Ajouter la gem rack-cors**
   ```ruby
   # Gemfile
   gem 'rack-cors'
   ```

2. **Configurer CORS dans Rails**
   ```ruby
   # config/initializers/cors.rb
   Rails.application.config.middleware.insert_before 0, Rack::Cors do
     allow do
       origins "http://localhost:5173" # Frontend Vite
       resource "*",
         headers: :any,
         methods: [:get, :post, :put, :patch, :delete, :options, :head],
         credentials: true
     end
   end
   ```

#### Configuration Vue/Vite

1. **Configurer l'URL de l'API**
   ```javascript
   // .env
   VITE_API_URL=http://localhost:3000
   ```

2. **Configurer Axios (si utilisé)**
   ```javascript
   axios.defaults.withCredentials = true;
   ```

### Configuration Docker

Dans un environnement Docker, il faut faire attention à :

1. **Configuration des ports**
   - S'assurer que les ports sont correctement exposés dans `docker-compose.yml`
   - Utiliser les noms de service comme hostnames dans le réseau Docker

2. **Configuration CORS pour Docker**
   ```ruby
   # config/initializers/cors.rb
   Rails.application.config.middleware.insert_before 0, Rack::Cors do
     allow do
       origins "http://localhost:5173", "http://frontend:5173"
       resource "*",
         headers: :any,
         methods: [:get, :post, :put, :patch, :delete, :options, :head],
         credentials: true
     end
   end
   ```

3. **Configuration de l'URL de l'API dans Docker**
   ```yaml
   # docker-compose.yml
   frontend:
     environment:
       - VITE_API_URL=http://backend:3000
   ```

## Dépannage

Si vous rencontrez encore des erreurs CORS :

1. Vérifiez les en-têtes de réponse dans les DevTools du navigateur
2. Assurez-vous que le serveur backend est accessible
3. Vérifiez que les origines autorisées correspondent exactement à l'URL de votre frontend
4. En développement, vous pouvez temporairement désactiver CORS dans le navigateur (non recommandé en production)

## Ressources

- [Documentation officielle de rack-cors](https://github.com/cyu/rack-cors)
- [MDN Web Docs sur CORS](https://developer.mozilla.org/fr/docs/Web/HTTP/CORS)
- [Rails Guide sur la sécurité](https://guides.rubyonrails.org/security.html) 