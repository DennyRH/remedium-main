class WarehousePolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      if @user.owner_or_admin?
        scope.where(account_id: @user.account_id)
      else
        scope.where(id: @user.access_alloweds.map(&:warehouse_id), status: 0)
      end
    end
  end

  def index?
    @user.owner_or_admin?
  end

  def new?
    @user.owner_or_admin?
  end

  def create?
    @user.owner_or_admin?
  end

  def show?
    @user.owner_or_admin?
  end

  def edit?
    @user.owner_or_admin?
  end

  def update?
    @user.owner_or_admin?
  end

  def destroy?
    @user.owner_or_admin?
  end

  def search_product?
    @user.owner_or_admin?
  end

  def search_items?
    @user.owner_or_admin?
  end

  def download_pdf?
    @user.owner_or_admin_or_sales?
  end

  def preview_pdf?
    @user.owner_or_admin_or_sales?
  end

end
