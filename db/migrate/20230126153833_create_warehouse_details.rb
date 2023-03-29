class CreateWarehouseDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :warehouse_details do |t|
      t.string :address
      t.references :warehouse
      t.string :municipality
      t.integer :branch_code
      t.string :nit
      t.string :cuis
      t.string :cufd

      t.timestamps
    end
  end
end
