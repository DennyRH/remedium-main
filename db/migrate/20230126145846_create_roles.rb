class CreateRoles < ActiveRecord::Migration[7.0]
  def change
    create_table :roles do |t|
      t.string :name
      t.string :permissions
      t.integer :account_id
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
