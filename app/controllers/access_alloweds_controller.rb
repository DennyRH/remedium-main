class AccessAllowedsController < ApplicationController
  before_action :set_user
  before_action :set_access_allowed, only: :destroy
  before_action :set_breadcrumbs_access, only: %i[new create destroy]
  before_action :set_warehouses, only: %i[new create]

  def new
    @access_allowed = AccessAllowed.new
  end

  def create
    @access_allowed = AccessAllowed.new(access_allowed_params)
    @access_allowed.user = @user

    if @access_allowed.valid?
      @access_allowed.save
      notice_message = "Se asigno la sucursal #{@access_allowed.warehouse.name} con exito!"
      redirect_to users_admin_path(@access_allowed.user), notice: notice_message
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    notice = "Se borro el Acceso de #{@access_allowed.user.full_name} a la sucursal #{@access_allowed.warehouse.name}"

    if @access_allowed.destroy
      redirect_to users_admin_path(@access_allowed.user_id), notice: notice
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def search_warehouse
    @warehouses = search_warehouse_filters

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          'search_results_warehouse_reference',
          partial: 'shared/searchs/search_results_warehouse',
          locals: { warehouses: @warehouses }
        )
      end
    end
  end

  private

  def access_allowed_params
    params.require(:access_allowed).permit(:id, :user_id, :warehouse_id)
  end

  def set_access_allowed
    @access_allowed = AccessAllowed.find(params[:id])
    authorize @access_allowed
  end

  def set_user
    @user = User.find(params[:users_admin_id])
    authorize @user
  end

  def set_warehouses
    @warehouses = current_user.account.warehouses.map do |warehouse|
      [warehouse.name, warehouse.id]
    end
  end

  def search_warehouse_filters
    if params[:search_warehouse].present?
      warehouses = Warehouse.joins(:warehouse_detail).where(
        'LOWER(name) LIKE :query OR LOWER(warehouse_details.address) LIKE :query OR LOWER(warehouse_details.branch_code) LIKE :query',
        query: "%#{params[:search_warehouse].downcase}%"
      ).where(account_id: current_account.id, status: 0).limit(30)

      warehouses.any? ? warehouses : []
    else
      []
    end
  end

  def set_breadcrumbs_access
    add_breadcrumb 'Usuarios', :users_admin_index_path
    add_breadcrumb @user.name, users_admin_path(@user)
    add_breadcrumb "S. Asignada #{@access_allowed.warehouse.name}", users_admin_access_allowed_path(@user, @access_allowed) if @access_allowed
    add_breadcrumb 'Asignar Sucursal', new_users_admin_access_allowed_path(@user) if ['new', 'create'].include?(action_name)
    add_breadcrumb 'Editar', edit_users_admin_access_allowed_path(@user, @access_allowed) if action_name == 'edit'
  end
end
