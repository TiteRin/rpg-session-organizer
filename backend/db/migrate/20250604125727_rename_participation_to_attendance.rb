class RenameParticipationToAttendance < ActiveRecord::Migration[7.1]
  def change
    rename_table :participations, :attendances
  end
end
