class MakeSnacksOptional < ActiveRecord::Migration[7.1]
  def change
    change_column_null :participations, :snacks, true
  end
end
