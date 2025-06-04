class Session < ApplicationRecord
    has_many :attendances
    has_many :players, through: :attendances
end
