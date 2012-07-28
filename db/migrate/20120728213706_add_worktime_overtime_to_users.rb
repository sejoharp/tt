class AddWorktimeOvertimeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :worktime, :integer
    add_column :users, :overtime, :integer
  end
end
