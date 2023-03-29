class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts do |t|
      t.string :name
      t.string :nit
      t.string :phone
      t.string :email
      t.text :digital_certificate
      t.text :private_key
      t.string :municipality
      t.string :sector_type_document
      t.string :address
      t.string :invoice_type
      t.string :bussiness_type
      t.string :type_of_taxpayer
      t.string :economic_activity
      t.string :social_reason

      t.timestamps
    end
  end
end
