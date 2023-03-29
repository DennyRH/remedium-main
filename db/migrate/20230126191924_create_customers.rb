class CreateCustomers < ActiveRecord::Migration[7.0]
  def change
    create_table :customers do |t|
      t.string :document_number
      t.string :name
      t.string :email
      t.string :type
      t.string :phone
      t.references :account
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
