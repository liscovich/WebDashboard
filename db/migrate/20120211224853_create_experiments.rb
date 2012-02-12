class CreateExperiments < ActiveRecord::Migration
  def change
    create_table :experiments do |t|
      t.belongs_to :creator
      
      t.string :name
      t.text   :short_description
      
      t.string   :title
      t.text     :description
      t.integer  :init_endow, :cost_defect, :cost_coop, :totalplayers, :humanplayers
      t.decimal  :contprob, :ind_payoff_shares, :precision => 10, :scale => 2
      t.decimal  :exchange_rate,                :precision => 10, :scale => 3

      t.datetime :created_at
    end
  end
end
