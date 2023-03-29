class CreateItemTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :item_transactions do |t|
      t.integer :qty
      t.integer :stock_at
      t.float :sub_total
      t.references :item, null: false, foreign_key: true
      t.references :transaktion, null: false, foreign_key: true

      t.timestamps
    end
  end
end
