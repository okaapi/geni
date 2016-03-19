class CreateUnions < ActiveRecord::Migration
  def change
    create_table :unions do |t|
      t.string :uid
      t.string :husband_uid
      t.string :wife_uid
      t.integer :marriage_id
      t.integer :divorce_id
      t.string :divorced
      t.string :tree
      t.text :note
      t.string :gedfile  
      t.text :gedraw
      t.integer :ver, default: 0
      t.integer :user_id

      t.timestamps
    end
  end
end
