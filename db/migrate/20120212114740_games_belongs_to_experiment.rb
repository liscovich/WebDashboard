class GamesBelongsToExperiment < ActiveRecord::Migration
  def up
    add_column :games, :experiment_id, :integer
    add_index  :games, :experiment_id
  end

  def down
    remove_column :games, :experiment_id
  end
end
