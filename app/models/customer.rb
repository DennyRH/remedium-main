class Customer < ApplicationRecord
  has_many :transaktions
  belongs_to :account
  validates :account_id, :name, :document_number, presence: true
  
  enum status: %i[active deleted]

  def status_es
    case status
    when 'active' then 'Activo'
    when 'deleted' then 'Eliminado'
    end
  end
end

# == Schema Information
#
# Table name: customers
#
#  id              :bigint           not null, primary key
#  document_number :string(255)
#  email           :string(255)
#  name            :string(255)
#  phone           :string(255)
#  status          :integer          default("active")
#  type            :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  account_id      :bigint
#
# Indexes
#
#  index_customers_on_account_id  (account_id)
#
