class BuyerPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.where(account_id: @user.account_id)
    end
  end

  def index?
    @user.owner_or_admin?
  end

  def new?
    @user.owner_or_admin?
  end

  def create?
    @user.owner_or_admin_or_sales?
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
end