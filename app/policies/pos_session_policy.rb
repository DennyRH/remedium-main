class PosSessionPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      if @user.owner_or_admin?
        scope.where(warehouse_id: @user.account.warehouses)
      else
        scope.where(user_id: @user.id)
      end
    end
  end

  def index?
    @user.owner_or_admin_or_sales?
  end

  def new?
    @user.owner_or_admin_or_sales?
  end

  def create?
    @user.owner_or_admin_or_sales?
  end

  def show?
    @user.owner_or_admin? || @record.user_id == @user.id
  end

  def edit?
    true
  end

  def update?
    true
  end

  def destroy?
    @user.owner_or_admin?
  end

  def purchases?
    @user.owner_or_admin?
  end

  def sales?
    @user.owner_or_admin_or_sales?
  end

  def create_sales_with_customer?
    @user.owner_or_admin_or_sales?
  end

  def create_item_transfer?
    @user.owner_or_admin_or_sales?
  end

  def annullated?
    @user.owner_or_admin?
  end

  def paying?
    @user.owner_or_admin?
  end

  def market_rates?
    @user.owner_or_admin_or_sales?
  end

  def item_transfer?
    @user.owner_or_admin?
  end

  def search_transaktions?
    @user.owner_or_admin_or_sales?
  end

  def search_product_purchase?
    @user.owner_or_admin_or_sales?
  end

  def search_product_sale?
    @user.owner_or_admin_or_sales?
  end

  def search_provider?
    @user.owner_or_admin_or_sales?
  end

  def search_market_rates?
    @user.owner_or_admin_or_sales?
  end

  def search_warehouse?
    @user.owner_or_admin_or_sales?
  end

  def item_transactions_session?
    @user.owner_or_admin_or_sales?
  end

  def modal_create_product?
    @user.owner_or_admin?
  end

  def modal_confirm_market_rates?
    @user.owner_or_admin_or_sales?
  end

  def modal_confirm_transfer?
    @user.owner_or_admin_or_sales?
  end

  def delete_session?
    @user.owner_or_admin_or_sales?
  end

  def delete_all_session?
    @user.owner_or_admin_or_sales?
  end
end
