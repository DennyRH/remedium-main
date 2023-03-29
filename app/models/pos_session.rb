class PosSession < ApplicationRecord
  belongs_to :warehouse

  has_many :transaktions
  has_many :archings

  validates :petty_cash, :user_id, numericality: true, presence: true
  validates :type_of_currency, presence: true

  enum status: %i[active deleted closed validating]

  def user
    User.find(user_id)
  end

  def session_responsible
    "#{user.short_name} (Caja: #{id})"
  end

  STATUS_ES = {
    'active' => 'Activo', 'deleted' => 'Eliminado', 'closed' => 'Cerrado',
    'validating' => 'Validando'
  }.freeze

  def status_es
    STATUS_ES[status]
  end
end

# == Schema Information
#
# Table name: pos_sessions
#
#  id                    :bigint           not null, primary key
#  initial_balance       :float(24)        default(0.0)
#  missing_money         :float(24)
#  observation           :string(255)
#  petty_cash            :float(24)
#  remaining_money       :float(24)
#  status                :integer          default("active")
#  total_balance         :float(24)
#  total_expenses        :float(24)
#  total_income          :float(24)
#  total_payment_methods :json
#  total_session         :float(24)
#  type_of_currency      :string(255)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  user_id               :integer          not null
#  warehouse_id          :bigint           not null
#
# Indexes
#
#  index_pos_sessions_on_warehouse_id  (warehouse_id)
#
# Foreign Keys
#
#  fk_rails_...  (warehouse_id => warehouses.id)
#
