class Attendance < ApplicationRecord
  belongs_to :player
  belongs_to :session
end
