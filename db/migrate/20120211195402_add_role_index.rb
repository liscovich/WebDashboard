class AddRoleIndex < ActiveRecord::Migration
  def up
    add_index :users, :role
  end

  def down
    remove_index :users, :role
  end
end
