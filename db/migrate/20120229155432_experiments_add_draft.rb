class ExperimentsAddDraft < ActiveRecord::Migration
  def up
    add_column :experiments, :draft, :boolean
    Experiment.update_all :draft => false
  end

  def down
    remove_column :experiments, :draft
  end
end
