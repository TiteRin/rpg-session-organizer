class CreateSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :sessions do |t|
      t.string :title
      t.text :recap
      t.datetime :scheduled_at

      t.timestamps
    end
  end
end
