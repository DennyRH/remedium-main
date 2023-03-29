class ItemPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.all
    end
  end

  def index?
    @user.owner_or_admin_or_sales?
  end

  def new?
    @user.owner_or_admin?
  end

  def create?
    @user.owner_or_admin?
  end

  def show?
    @user.owner_or_admin_or_sales?
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
    @user.owner_or_admin_or_sales?
  end

  def search_items?
    @user.owner_or_admin_or_sales?
  end
end
