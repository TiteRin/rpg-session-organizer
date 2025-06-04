class Player < ApplicationRecord
    has_many :participations
    has_many :sessions, through: :participations
end
