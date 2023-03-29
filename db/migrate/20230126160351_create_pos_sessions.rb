class CreatePosSessions < ActiveRecord::Migration[7.0]
  def change
    create_table :pos_sessions do |t|
      t.references :warehouse, null: false, foreign_key: true
      t.float :petty_cash
      t.string :observation
      t.string :type_of_currency
      t.integer :status, default: 0
      t.integer :user_id, null: false
      t.float :total_balance
      t.float :initial_balance, default: 0
      t.float :missing_money
      t.float :remaining_money
      t.float :total_income
      t.float :total_expenses
      t.float :total_session
      t.json :total_payment_methods

      t.timestamps
    end
  end
end
