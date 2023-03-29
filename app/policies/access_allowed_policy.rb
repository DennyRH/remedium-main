class AccessAllowedPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.all
    end
  end

  def new?
    @user.owner_or_admin?
  end

  def create?
    @user.owner_or_admin?
  end

  def destroy?
    @user.owner_or_admin?
  end
end
