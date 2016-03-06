class CreateIndividuals < ActiveRecord::Migration
  def change
    create_table :individuals do |t|
      t.string :name
      t.string :surname
      t.string :given
      t.string :nickname
      t.string :prefix
      t.string :suffix
      t.string :pedigree
      t.string :sex
      t.integer :birth_id
      t.integer :death_id
      t.string :uid
      t.string :parents_uid
      t.text :changed_ged
      t.string :tree
      t.string :gedfile
      t.text :note
      t.text :gedraw
      t.integer :ver, default: 0
      t.integer :user_id

      t.timestamps
    end
  end
end
