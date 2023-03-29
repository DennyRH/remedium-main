class Account < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :warehouses, dependent: :destroy
  has_many :customers

  validates :name, presence: true, uniqueness: true, length: { minimum: 3 }
  validates :email, presence: true
end

# == Schema Information
#
# Table name: accounts
#
#  id                   :bigint           not null, primary key
#  address              :string(255)
#  bussiness_type       :string(255)
#  digital_certificate  :text(65535)
#  economic_activity    :string(255)
#  email                :string(255)
#  invoice_type         :string(255)
#  municipality         :string(255)
#  name                 :string(255)
#  nit                  :string(255)
#  phone                :string(255)
#  private_key          :text(65535)
#  sector_type_document :string(255)
#  social_reason        :string(255)
#  type_of_taxpayer     :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
