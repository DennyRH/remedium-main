class Invoice < ApplicationRecord
  belongs_to :transaktion

  enum status: %i[reception validated canceled]
end

# == Schema Information
#
# Table name: invoices
#
#  id                            :bigint           not null, primary key
#  branch_code                   :integer
#  card_number                   :string(255)
#  client_code                   :string(255)
#  complement                    :string(255)
#  cuf                           :string(255)
#  cufd                          :string(255)
#  currency_code                 :string(255)
#  date_of_issue                 :string(255)
#  description                   :string(255)
#  digest_value                  :string(255)
#  direction                     :string(255)
#  discount_amount               :string(255)
#  document_number               :string(255)
#  economic_activity             :string(255)
#  exchange_rate                 :string(255)
#  identity_document_type_code   :string(255)
#  imei_number                   :string(255)
#  legend                        :string(255)
#  municipality                  :string(255)
#  name_or_social_reason         :string(255)
#  name_or_social_reason_emitter :string(255)
#  nit_emitter                   :string(255)
#  number_facture                :string(255)
#  payment_method_code           :string(255)
#  phone                         :string(255)
#  point_of_sale_code            :string(255)
#  product_code                  :string(255)
#  product_code_sin              :string(255)
#  sector_document_code          :string(255)
#  serial_number                 :string(255)
#  signature_value               :string(255)
#  status                        :integer          default("reception")
#  sub_total                     :string(255)
#  total                         :string(255)
#  total_amount                  :string(255)
#  total_amount_currency         :string(255)
#  total_amount_subject_iva      :string(255)
#  unit_of_measure               :string(255)
#  unit_price                    :string(255)
#  user                          :string(255)
#  x_509_certificate             :string(255)
#  x_509_issuer_name             :string(255)
#  x_509_serial_number           :string(255)
#  x_509_subject_name            :string(255)
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  transaktion_id                :bigint           not null
#
# Indexes
#
#  index_invoices_on_transaktion_id  (transaktion_id)
#
# Foreign Keys
#
#  fk_rails_...  (transaktion_id => transaktions.id)
#
