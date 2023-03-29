class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table :items do |t|
      t.references :warehouse, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.string :code
      t.integer :total_stock
      t.integer :quantity
      t.integer :min_stock
      t.integer :max_stock
      t.float :list_price
      t.float :sale_price_unit
      t.float :sale_price_package
      t.float :purchase_cost_unit
      t.float :purchase_cost_package
      t.date :expiration_date
      t.date :date_of_elaboration
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
