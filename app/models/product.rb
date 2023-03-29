class Product < ApplicationRecord
  has_many :items
  has_many :warehouses, through: :items
  has_one :customer

  accepts_nested_attributes_for :items

  validates :name, :description, :presentation, :generic_name,
            :unit, :package, :category, :sub_category, :trademark, presence: true
  validates :total_unit, :account_id, presence: true, numericality: true

  enum status: %i[active deleted]

  def customer
    Customer.find(customer_id)
  end

  def status_es
    case status
    when 'active' then 'Activo'
    when 'deleted' then 'Eliminado'
    end
  end
end

# == Schema Information
#
# Table name: products
#
#  id               :bigint           not null, primary key
#  alternative_code :string(255)
#  category         :string(255)
#  characteristics  :string(255)
#  code             :string(255)
#  controled        :boolean
#  description      :string(255)
#  generic_name     :string(255)
#  industry         :string(255)
#  model_rrss       :string(255)
#  name             :string(255)
#  package          :string(255)
#  presentation     :string(255)
#  status           :integer          default("active")
#  sub_category     :string(255)
#  taxes            :boolean
#  total_unit       :integer          default(1)
#  trademark        :string(255)
#  unit             :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  account_id       :integer
#  customer_id      :integer
#  import_id        :string(255)
#
