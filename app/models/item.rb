class Item < ApplicationRecord
  belongs_to :warehouse
  belongs_to :product

  has_many :item_transations

  validates :quantity, :total_stock, :sale_price_package, :sale_price_unit,
            :purchase_cost_package, :purchase_cost_unit, presence: true, numericality: true
  validates :code, presence: true

  before_validation :normalize_price_package, if: :sale_price_package.nil?

  enum status: %i[active deleted]

  #delegate :description, :to => :product

  private

  def normalize_price_package
    self.sale_price_package = self.sale_price_unit * product.total_unit
  end
end

# == Schema Information
#
# Table name: items
#
#  id                    :bigint           not null, primary key
#  code                  :string(255)
#  date_of_elaboration   :date
#  expiration_date       :date
#  list_price            :float(24)
#  max_stock             :integer
#  min_stock             :integer
#  purchase_cost_package :float(24)
#  purchase_cost_unit    :float(24)
#  quantity              :integer
#  sale_price_package    :float(24)
#  sale_price_unit       :float(24)
#  status                :integer          default("active")
#  total_stock           :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  product_id            :bigint           not null
#  warehouse_id          :bigint           not null
#
# Indexes
#
#  index_items_on_product_id    (product_id)
#  index_items_on_warehouse_id  (warehouse_id)
#
# Foreign Keys
#
#  fk_rails_...  (product_id => products.id)
#  fk_rails_...  (warehouse_id => warehouses.id)
#
