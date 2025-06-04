# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Clear existing data
puts "Cleaning database..."
Participation.destroy_all
Session.destroy_all
Player.destroy_all

# Create players
puts "Creating players..."
players = [
  { name: "Alice" },
  { name: "Bob" },
  { name: "Charlie" },
  { name: "Diana" },
  { name: "Eve" }
]

players.each do |player_data|
  Player.create!(player_data)
end

# Create sessions
puts "Creating sessions..."
sessions = [
  {
    title: "Session 1: The Beginning",
    scheduled_at: 1.week.ago,
    recap: "The party met in a tavern and received their first quest."
  },
  {
    title: "Session 2: The Forest of Shadows",
    scheduled_at: 3.days.ago,
    recap: "The party ventured into the dark forest and encountered strange creatures."
  },
  {
    title: "Session 3: The Ancient Ruins",
    scheduled_at: 2.days.from_now,
    recap: nil
  },
  {
    title: "Session 4: The Final Battle",
    scheduled_at: 1.week.from_now,
    recap: nil
  }
]

sessions.each do |session_data|
  Session.create!(session_data)
end

# Create participations
puts "Creating participations..."
# Past sessions (1 and 2)
Session.where("scheduled_at < ?", Time.current).each do |session|
  Player.all.each do |player|
    Participation.create!(
      player: player,
      session: session,
      presence: [true, false].sample,
      snacks: ["snacks", "drinks", "dice", "character_sheet"].sample
    )
  end
end

# Future sessions (3 and 4)
Session.where("scheduled_at > ?", Time.current).each do |session|
  Player.all.each do |player|
    Participation.create!(
      player: player,
      session: session,
      presence: [true, false].sample,
      snacks: nil
    )
  end
end

puts "Seed completed!"
