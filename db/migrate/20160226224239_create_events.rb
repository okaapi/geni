class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :date
      t.integer :year
      t.integer :month
      t.integer :day
      t.string :location
      t.text :text

      t.timestamps
    end
  end
end
