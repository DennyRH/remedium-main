class Buyer < Customer
  alias_attribute :ci_or_nit, :document_number
  alias_attribute :name_or_social_reason, :name
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
