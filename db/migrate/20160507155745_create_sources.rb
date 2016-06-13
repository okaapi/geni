class CreateSources < ActiveRecord::Migration
  def change
    create_table :sources do |t|
      t.string :title
      t.text :content
      t.string :filename
      t.string :sid
      t.string :tree
      t.string :gedfile
      t.text :gedraw

      t.timestamps null: false
    end
  end
end
