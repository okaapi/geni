class CreateSourceRefs < ActiveRecord::Migration
  def change
    create_table :source_refs do |t|
      t.string :individual_uid
      t.string :union_uid
      t.integer :source_id

      t.timestamps null: false
    end
  end
end
