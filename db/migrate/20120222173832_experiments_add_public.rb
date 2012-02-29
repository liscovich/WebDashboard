class ExperimentsAddPublic < ActiveRecord::Migration
  def up
    add_column :experiments, :public, :boolean
    add_index  :experiments, :public
    
    Experiment.update_all :public => true
  end

  def down
    remove_column :experiments, :public
  end
end
