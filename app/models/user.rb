class User < ApplicationRecord
  belongs_to :account
  belongs_to :role

  has_many :access_alloweds
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  enum status: %i[active deleted]

  def full_name
    "#{name} #{last_name}"
  end

  def sales?
    role.name == 'sales'
  end

  def admin?
    role.name == 'admin'
  end

  def owner?
    role.name == 'owner'
  end

  def owner_or_admin?
    role.name == 'owner' || role.name == 'admin'
  end

  def owner_or_admin_or_sales?
    %w[owner admin sales].include?(role.name)
  end

  def short_name
    if name? && last_name?
      if name.length > 10
        "#{name.split(' ')[0].capitalize} #{last_name.first(1).capitalize}."
      else
        "#{name.capitalize} #{last_name.first(1).capitalize}."
      end
    elsif name? && !last_name?
      name.capitalize
    elsif !name? && last_name?
      last_name.capitalize
    else
      ''
    end
  end

  def assigned_warehouses
    if self.sales?
      Warehouse.where(id: access_alloweds.map(&:warehouse_id))
    else
      account.warehouses
    end
  end
end

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  ci                     :string(255)
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  last_name              :string(255)
#  name                   :string(255)
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string(255)
#  status                 :integer          default("active")
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  account_id             :bigint
#  role_id                :bigint
#
# Indexes
#
#  index_users_on_account_id            (account_id)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_role_id               (role_id)
#
