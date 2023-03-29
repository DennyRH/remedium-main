class CreateTransaktions < ActiveRecord::Migration[7.0]
  def change
    create_table :transaktions do |t|
      t.references :customer, foreign_key: true
      t.references :pos_session, null: false, foreign_key: true
      t.string :type_transaktion
      t.float :total
      t.string :description
      t.float :money_received
      t.float :money_returned
      t.string :payment_method
      t.string :code
      t.string :discount
      t.float :money_paid
      t.integer :destination_warehouse_id
      t.integer :receiver_pos_session_id
      t.date :date_of_payment
      t.integer :invoice_number
      t.integer :receipt_number
      t.integer :customer_received_money_id
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
