class Player < ApplicationRecord
    has_many :attendances
    has_many :sessions, through: :attendances
end
