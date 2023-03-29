class AccountsController < ApplicationController
  before_action :set_account, only: %i[show edit update destroy]
  before_action :set_breadcrumbs, only: %i[show edit]
  before_action :skip_authorization, only: :create

  def create
    @account = Account.new(account_params)
    authorize @account
    notice_message = "Se Creo la cuenta #{@account.name} con exito!"

    if @account.valid?
      @account.save
      redirect_to account_path(@account), notice: notice_message
    else
      render 'users/sign_up', status: :unprocessable_entity
    end
  end

  def show; end
  def edit; end

  def update
    if @account.update(account_params)
      notice_message = "Se Actualizo la cuenta #{@account.name} con exito!"
      redirect_to account_path(@account), notice: notice_message
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    notice_message = "Se Elimino la cuenta #{@account.name} con exito!"

    if @account.destroy
      redirect_to destroy_user_session_path, notice: notice_message
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  private

  def set_account
    @account = Account.find(params[:id])
    authorize @account
  end

  def account_params
    params.require(:account).permit(
      :id, :name, :nit, :phone, :email, :municipality, :sector_type_document,
      :address, :invoice_type, :bussiness_type, :type_of_taxpayer, :economic_activity,
      :social_reason
    )
  end

  def set_breadcrumbs
    add_breadcrumb @account.name, :account_path
    add_breadcrumb 'Editar', edit_account_path(@account) if action_name == 'edit'
  end
end
