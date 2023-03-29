class WarehousesController < ApplicationController
  before_action :set_warehouse, only: %i[show edit update destroy]
  before_action :set_account, only: %i[index new create]
  before_action :set_breadcrumbs_customers, only: %i[index new edit show create update]
  before_action :skip_authorization, only: :search_warehouses

  def index
    @warehouses = policy_scope(Warehouse).page(params[:page]).per(12).order(id: :desc)
    authorize @warehouses
  end

  def search_warehouses
    @warehouses = search_warehouses_filter

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          'search_results_warehouses_index',
          partial: 'shared/cards/card_warehouse',
          locals: { warehouses: @warehouses }
        )
      end
    end
  end

  def new
    @warehouse = Warehouse.new(account_id: @account.id)
    @warehouse.warehouse_detail = WarehouseDetail.new
    authorize @warehouse
  end

  def create
    @warehouse = Warehouse.new(**warehouse_params, account_id: @account.id)
    authorize @warehouse

    if @warehouse.valid?
      @warehouse.save
      notice_message = "Se creo la sucursal #{@warehouse.name}, con exito!"
      redirect_to warehouse_path(@warehouse), notice: notice_message
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def show; end

  def edit
    @warehouse_detail = @warehouse.warehouse_detail || WarehouseDetail.new(warehouse: @warehouse)
  end

  def update
    if @warehouse.update(warehouse_params)
      notice_message = "Se Actualizo la sucursal #{@warehouse.name}, con exito!"
      redirect_to warehouse_path(@warehouse), notice: notice_message
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    notice_message = "Se Elimino la sucursal #{@warehouse.name}, con exito!"

    if @warehouse.update(status: 1)
      redirect_to warehouses_path, notice: notice_message
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  private

  def warehouse_params
    params.require(:warehouse).permit(
      :id, :name,
      warehouse_detail_attributes: %i[nit branch_code municipality address]
    )
  end

  def set_warehouse
    @warehouse = Warehouse.find(params[:id])
    redirect_to warehouses_path if @warehouse.status == 'deleted'
    authorize @warehouse
  end

  def set_account
    @account = Account.find(current_account&.id)
  end

  def set_breadcrumbs_customers
    add_breadcrumb 'Sucursales', :warehouses_path
    add_breadcrumb @warehouse.name, :warehouse_path if @warehouse
    add_breadcrumb 'Crear', :new_warehouse_path if ['new', 'create'].include?(action_name)
    add_breadcrumb 'Editar', :edit_warehouse_path if ['edit', 'update'].include?(action_name)
  end

  def search_warehouses_filter
    Warehouse.joins(:warehouse_detail).where(
      'LOWER(name) LIKE :query OR LOWER(warehouse_details.address) LIKE :query OR LOWER(warehouse_details.nit) LIKE :query OR LOWER(warehouse_details.branch_code) LIKE :query',
      query: "%#{params[:search_warehouses].downcase}%"
    ).where(account_id: current_account.id, status: 0).limit(30)
  end
end
