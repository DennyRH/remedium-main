class Warehouse < ApplicationRecord
  belongs_to :account
  has_one :warehouse_detail, dependent: :destroy
  accepts_nested_attributes_for :warehouse_detail

  has_many :pos_sessions
  has_many :access_alloweds
  has_many :items
  has_many :products, through: :items 

  validates :name, presence: true, length: { minimum: 3 }
  validates :name, uniqueness: true

  enum status: %i[active deleted]
end

# == Schema Information
#
# Table name: warehouses
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  status     :integer          default("active")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :bigint
#
# Indexes
#
#  index_warehouses_on_account_id  (account_id)
#
