class AddLinkToIndividuals < ActiveRecord::Migration
  def change
    add_column :individuals, :linkuid, :string, default: nil  
    add_column :individuals, :label, :string, default: ''  
  end
end
