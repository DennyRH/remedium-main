class Transaktion < ApplicationRecord
  belongs_to :customer, optional: true
  belongs_to :pos_session

  after_update :market_rate_confirm
  after_update :item_transfer_confirm

  has_one :invoice
  has_many :item_transactions

  validates :type_transaktion, :payment_method, presence: true
  validates :total, presence: true, numericality: true

  enum status: %i[active canceled annulled deleted invoiced valued sent pending]

  def receiver_pos_session
    PosSession.find(receiver_pos_session_id)
  end

  STATUS_ES = {
    'active' => 'Completado', 'canceled' => 'Cancelado', 'annulled' => 'Anulado',
    'deleted' => 'Eliminado', 'invoiced' => 'Facturado', 'valued' => 'Valorado',
    'sent' => 'Enviado', 'pending' => 'Pendiente'
  }.freeze

  def status_es
    STATUS_ES[status]
  end

  TRANSACTION_TYPES_ES = {
    'Purchases' => 'Compra', 'Purchases Credit' => 'Compra al Credito',
    'Sales' => 'Venta', 'Transfer' => 'Traspaso', 'Market rates' => 'Cotización'
  }.freeze

  def type_transaktion_es
    TRANSACTION_TYPES_ES[type_transaktion]
  end

  def purchase?
    type_transaktion == 'Purchases'
  end

  def purchase_credit?
    type_transaktion == 'Purchases Credit'
  end

  def sale?
    type_transaktion == 'Sales'
  end

  def market_rate?
    type_transaktion == 'Market rates'
  end

  def transfer?
    type_transaktion == 'Transfer'
  end

  def destination_warehouse
    Warehouse.find(destination_warehouse_id)
  end

  def market_rate_confirm
    if type_transaktion == 'Market rates' && status == 'active'
      item_transactions.each do |obj|
        item = Item.find(obj.item_id)
        item.update(
          total_stock: item.total_stock - obj.qty,
          quantity: item.quantity - (obj.qty / item.product.total_unit)
        )
        obj.update(stock_at: item.total_stock)
      end
    end
  end

  def item_transfer_confirm
    if type_transaktion == 'Transfer' && status == 'active' && receiver_pos_session_id
      item_transactions.each do |obj|
        item = Item.find(obj.item_id)
        item.update(
          total_stock: item.total_stock - obj.qty,
          quantity: item.quantity - (obj.qty / item.product.total_unit)
        )

        item_destination = Item.find_by(
          warehouse_id: destination_warehouse_id,
          product: item.product,
          status: 0
        )

        if item_destination
          item_destination.update(
            total_stock: item_destination.total_stock + obj.qty,
            quantity: item_destination.quantity + (obj.qty / item_destination.product.total_unit)
          )
        else
          new_item = Item.new(item.attributes)
          new_item.warehouse_id = destination_warehouse_id
          new_item.code = ''
          new_item.quantity = obj.qty / item.product.total_unit
          new_item.total_stock = obj.qty
          new_item.save
        end
        obj.update(stock_at: item.total_stock)
      end
    end
  end
end

# == Schema Information
#
# Table name: transaktions
#
#  id                         :bigint           not null, primary key
#  code                       :string(255)
#  date_of_payment            :date
#  description                :string(255)
#  discount                   :string(255)
#  invoice_number             :integer
#  money_paid                 :float(24)
#  money_received             :float(24)
#  money_returned             :float(24)
#  payment_method             :string(255)
#  receipt_number             :integer
#  status                     :integer          default("active")
#  total                      :float(24)
#  type_transaktion           :string(255)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  customer_id                :bigint
#  customer_received_money_id :integer
#  destination_warehouse_id   :integer
#  pos_session_id             :bigint           not null
#  receiver_pos_session_id    :integer
#
# Indexes
#
#  index_transaktions_on_customer_id     (customer_id)
#  index_transaktions_on_pos_session_id  (pos_session_id)
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => customers.id)
#  fk_rails_...  (pos_session_id => pos_sessions.id)
#
