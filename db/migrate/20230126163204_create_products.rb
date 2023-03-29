class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :name
      t.string :description
      t.string :presentation
      t.string :code
      t.string :alternative_code
      t.string :trademark
      t.string :characteristics
      t.string :model_rrss
      t.string :generic_name
      t.string :unit
      t.string :package
      t.string :category
      t.string :sub_category
      t.integer :total_unit, default: 1
      t.integer :customer_id
      t.integer :account_id
      t.string :import_id
      t.string :industry
      t.boolean :controled
      t.boolean :taxes
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
