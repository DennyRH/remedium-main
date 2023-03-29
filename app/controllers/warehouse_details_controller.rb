class WarehouseDetailsController < ApplicationController
  before_action :set_warehouse, only: %i[create update destroy]

  def create
    @warehouse_detail = WarehouseDetail.new(warehouse_detail_params)
    @warehouse_detail.warehouse = @warehouse
    if @warehouse_detail.save
      redirect_to warehouse_path(@warehouse)
    else
      render 'warehouses/edit', status: :unprocessable_entity
    end
  end

  def update
    @warehouse_detail = @warehouse.warehouse_detail

    if @warehouse_detail.update(warehouse_detail_params)
      redirect_to warehouse_path(@warehouse)
    else
      render 'warehouses/edit', status: :unprocessable_entity
    end
  end

  def destroy
    @warehouse_detail = @warehouse.warehouse_detail

    if @warehouse_detail.destroy
      redirect_to warehouses_path
    else
      render 'warehouses/edit', status: :unprocessable_entity
    end
  end

  private

  def warehouse_detail_params
    params.require(:warehouse_detail).permit(:address, :branch_code, :municipality, :nit)
  end

  def set_warehouse
    @warehouse = Warehouse.find(params[:warehouse_id])
  end
end
