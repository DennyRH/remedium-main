class OrdersController < ApplicationController
    before_action :skip_authorization, only: :index
    before_action :set_breadcrumbs, only: :index

    def index
        @warehouses_filtered = current_user.assigned_warehouses
        @provider = Customer.find(params[:provider_id]) if params[:provider_id].present?
        @items = set_item_filters

        last_month_date = Date.current.prev_month
        start_of_last_month = last_month_date.beginning_of_month
        end_of_last_month = last_month_date.end_of_month

        @items_suggestions = @items.map do |obj|
            item_solds = ItemTransaction.where(item_id: obj.id, created_at: start_of_last_month..end_of_last_month).sum(:qty)
            {
                code: obj.code, description: obj.product.description, warehouse_name: obj.warehouse.name,
                total_stock: obj.total_stock, total_items_sold: item_solds, min_stock: obj.min_stock,
                total_orders: item_solds - obj.total_stock, max_stock: obj.max_stock, provider_name: obj.product.customer.name
            }
        end
    end

    private

    def set_item_filters
        @warehouse_selected = Warehouse.find_by(id:params[:warehouse_filter])
        warehouse_ids = @warehouse_selected || @warehouses_filtered
        if @provider
            @items = Item.joins(:product).where(products: { customer_id: @provider.id })
                                         .where(items: { warehouse_id: warehouse_ids})
                                         .page(params[:page]).per(30)
        else
            @items = Item.where(warehouse_id: warehouse_ids ).page(params[:page]).per(30)
        end
    end

    def set_breadcrumbs
        add_breadcrumb 'Pedidos', orders_path
    end
end
