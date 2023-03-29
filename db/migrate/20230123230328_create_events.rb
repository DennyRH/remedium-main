class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.references :eventable, polymorphic: true, null: false
      t.string :name
      t.string :info
      t.string :info2

      t.timestamps
    end
  end
end
