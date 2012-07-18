class CreateIntervals < ActiveRecord::Migration
  def change
    create_table :intervals do |t|
      t.datetime :start
      t.datetime :stop
      t.references :user

      t.timestamps
    end
    add_index :intervals, :user_id
  end
end
