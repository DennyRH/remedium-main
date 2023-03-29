class AccessAllowed < ApplicationRecord
  belongs_to :user
  belongs_to :warehouse

  validates_uniqueness_of :user_id, scope: :warehouse_id
end

# == Schema Information
#
# Table name: access_alloweds
#
#  id           :bigint           not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint           not null
#  warehouse_id :bigint           not null
#
# Indexes
#
#  index_access_alloweds_on_user_id       (user_id)
#  index_access_alloweds_on_warehouse_id  (warehouse_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (warehouse_id => warehouses.id)
#
