class ApplicationController < ActionController::Base
  protect_from_forgery

  include Pundit::Authorization
  include ApplicationHelper

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  after_action :verify_authorized
  before_action :skip_authorization, if: :devise_controller?
  before_action :authenticate_user!

  add_breadcrumb 'Inicio', :root_path, unless: :devise_controller?

  private

  def after_sign_out_path_for(_resource_or_scope)
    session.delete(:item_transactions_purchase)
    session.delete(:item_transactions_sales)
    session.delete(:item_transactions_market_rates)
    session.delete(:item_transactions_transfer)
    new_user_session_path
  end

  def after_sign_up_path_for(_resource_or_scope)
    root_path
  end

  def user_not_authorized
    flash[:alert] = "No estás autorizado para realizar esta acción"
    redirect_back fallback_location: root_path
  end
end
