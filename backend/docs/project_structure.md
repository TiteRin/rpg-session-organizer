# RPG Session Organizer - Project Structure

## Database Schema


### SchemaMigration

- `version`: string



### ArInternalMetadatum

- `key`: string

- `value`: string (nullable)

- `created_at`: datetime

- `updated_at`: datetime



### Session

- `id`: integer (primary key)

- `title`: string (nullable)

- `recap`: text (nullable)

- `scheduled_at`: datetime (nullable)

- `created_at`: datetime

- `updated_at`: datetime



### Player

- `id`: integer (primary key)

- `name`: string (nullable)

- `created_at`: datetime

- `updated_at`: datetime



### Participation

- `id`: integer (primary key)

- `presence`: boolean (nullable)

- `snacks`: text (nullable)

- `player_id`: integer

- `session_id`: integer

- `created_at`: datetime

- `updated_at`: datetime




## Model Relationships

### Participation
```ruby
class Participation < ApplicationRecord
  belongs_to :player
  belongs_to :session
end
```

### Player
```ruby
class Player < ApplicationRecord
  has_many :participations
  has_many :sessions
end
```

### Session
```ruby
class Session < ApplicationRecord
  has_many :participations
  has_many :players
end
```


## API Endpoints


### Participation

- POST `/api/sessions/:session_id/participations` - create



### Session

- GET `/api/sessions` - index

- POST `/api/sessions` - create

- GET `/api/sessions/:id` - show



