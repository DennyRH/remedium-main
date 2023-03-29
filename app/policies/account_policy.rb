class AccountPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.all if @user.owner?
    end
  end

  def show?
    @user.owner?
  end

  def edit?
    @user.owner?
  end

  def update?
    @user.owner?
  end

  def destroy?
    @user.owner?
  end
end
