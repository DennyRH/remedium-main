class WarehouseDetail < ApplicationRecord
  belongs_to :warehouse

  validates :address, presence: true, length: { minimum: 4 }
  validates :municipality, presence: true, length: { minimum: 4 }
  validates :branch_code, presence: true, numericality: true
  validates :nit, presence: true,  length: { minimum: 7 }
end

# == Schema Information
#
# Table name: warehouse_details
#
#  id           :bigint           not null, primary key
#  address      :string(255)
#  branch_code  :integer
#  cufd         :string(255)
#  cuis         :string(255)
#  municipality :string(255)
#  nit          :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  warehouse_id :bigint
#
# Indexes
#
#  index_warehouse_details_on_warehouse_id  (warehouse_id)
#
