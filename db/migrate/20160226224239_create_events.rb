class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :rawdate
      t.datetime :date
      t.string :location
      t.text :text

      t.timestamps
    end
  end
end
