class CreateWarehouses < ActiveRecord::Migration[7.0]
  def change
    create_table :warehouses do |t|
      t.string :name
      t.references :account
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
