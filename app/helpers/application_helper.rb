module ApplicationHelper
  def current_account
    current_user&.account
  end
end
