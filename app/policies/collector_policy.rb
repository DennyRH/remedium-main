class CollectorPolicy < ApplicationPolicy
    class Scope < Scope
      # NOTE: Be explicit about which records you allow access to!
      def resolve
        scope.where(account_id: @user.account_id)
      end
    end
    
    def create?
      @user.owner_or_admin_or_sales?
    end
  end