class ItemTransaction < ApplicationRecord
  belongs_to :item
  belongs_to :transaktion
  after_create :sum_or_rest_item

  validates :qty, :sub_total, presence: true, numericality: true

  def sum_or_rest_item
    if transaktion.type_transaktion == 'Purchases' || transaktion.type_transaktion == 'Purchases Credit'
      item.update(
        total_stock: item.total_stock + qty,
        quantity: item.quantity + (qty / item.product.total_unit)
      )
      update(stock_at: item.total_stock)
    elsif transaktion.type_transaktion == 'Sales'
      item.update(
        total_stock: item.total_stock - qty,
        quantity: item.quantity - (qty / item.product.total_unit)
      )
      update(stock_at: item.total_stock)
    end
  end
end

# == Schema Information
#
# Table name: item_transactions
#
#  id             :bigint           not null, primary key
#  qty            :integer
#  stock_at       :integer
#  sub_total      :float(24)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  item_id        :bigint           not null
#  transaktion_id :bigint           not null
#
# Indexes
#
#  index_item_transactions_on_item_id         (item_id)
#  index_item_transactions_on_transaktion_id  (transaktion_id)
#
# Foreign Keys
#
#  fk_rails_...  (item_id => items.id)
#  fk_rails_...  (transaktion_id => transaktions.id)
#
