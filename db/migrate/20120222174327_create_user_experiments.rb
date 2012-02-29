class CreateUserExperiments < ActiveRecord::Migration
  def change
    create_table :user_experiments do |t|
      t.belongs_to :user
      t.belongs_to :experiment
      t.integer    :role, :limit => 3
    end

    add_index :user_experiments, [:user_id, :experiment_id]
  end
end
