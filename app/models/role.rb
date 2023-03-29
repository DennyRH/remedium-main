class Role < ApplicationRecord
  has_many :users

  validates :name, presence: true, length: { minimum: 4 }
  validates :account_id, presence: true, numericality: true

  enum status: %i[active deleted]

  NAME_ES = {
    'owner' => 'Propietario', 'admin' => 'Administrador', 'sales' => 'Vendedor'
  }.freeze

  def name_es
    NAME_ES[name]
  end
end

# == Schema Information
#
# Table name: roles
#
#  id          :bigint           not null, primary key
#  name        :string(255)
#  permissions :string(255)
#  status      :integer          default("active")
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  account_id  :integer
#
