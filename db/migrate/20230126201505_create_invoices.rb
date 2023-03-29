class CreateInvoices < ActiveRecord::Migration[7.0]
  def change
    create_table :invoices do |t|
      t.string :nit_emitter
      t.string :name_or_social_reason_emitter
      t.string :total
      t.references :transaktion, null: false, foreign_key: true
      t.string :municipality
      t.string :phone
      t.string :cuf
      t.string :cufd
      t.integer :branch_code
      t.string :direction
      t.string :point_of_sale_code
      t.string :date_of_issue
      t.string :number_facture
      t.string :name_or_social_reason
      t.string :identity_document_type_code
      t.string :document_number
      t.string :complement
      t.string :client_code
      t.string :payment_method_code
      t.string :card_number
      t.string :total_amount
      t.string :total_amount_subject_iva
      t.string :currency_code
      t.string :exchange_rate
      t.string :total_amount_currency
      t.string :legend
      t.string :user
      t.string :sector_document_code
      t.string :economic_activity
      t.string :product_code_sin
      t.string :product_code
      t.string :description
      t.string :unit_of_measure
      t.string :unit_price
      t.string :discount_amount
      t.string :sub_total
      t.string :serial_number
      t.string :imei_number
      t.string :digest_value
      t.string :signature_value
      t.string :x_509_certificate
      t.string :x_509_subject_name
      t.string :x_509_issuer_name
      t.string :x_509_serial_number
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
