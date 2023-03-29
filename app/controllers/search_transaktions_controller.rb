class SearchTransaktionsController < ApplicationController
  before_action :set_pos_session

  def search_transaktions
    @transaktions = search_transaktions_filter

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          'transaktions_movements_search',
          partial: 'shared/tables/table_transaktion',
          locals: { transaktions: @transaktions }
        )
      end
    end
  end

  def search_provider
    @customers = search_customers_filters

    respond_to do |format|
      format.json { render json: @customers[0]&.to_json }
    end
  end

  def search_product_purchase
    @items = filter_search_purchase(params[:search], params[:customer_id])

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          'search_results_purchase',
          partial: 'search_transaktions/search_results_purchase',
          locals: { products: @items }
        )
      end
    end
  end

  def search_product_sale
    @items = filter_search_sale
    turbo_frame_id, partial_result = set_data_search_product_sale

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          turbo_frame_id, partial: partial_result, locals: { products: @items }
        )
      end
    end
  end

  def search_market_rates
    @market_rates = Transaktion.where(
      id: params[:search_market_rates], type_transaktion: 'Market rates', status: 'valued'
    )

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          'search_results_confirm_market_rates',
          partial: 'search_transaktions/search_results_confirm_market_rates',
          locals: { market_rates: @market_rates }
        )
      end
    end
  end

  def search_warehouse
    @warehouses = search_warehouse_filters

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          'search_results_transfer_warehouse',
          partial: 'search_transaktions/search_results_transfer_warehouse',
          locals: { warehouses: @warehouses }
        )
      end
    end
  end

  def create_sales_with_customer
    customer = Customer.find_by_id(params[:customer_id])
    @payment_methods = ['Efectivo', 'Pago QR', 'Tarjeta', 'Transferencia']
    if customer.nil? && params[:document_number].present? && params[:name].present?
      customer = Buyer.create(
        document_number: params[:document_number], name: params[:name],
        account_id: current_account.id, email: params[:email]
      )
    end

    transaktion = Transaktion.new(
      type_transaktions_params.merge(pos_session_id: @pos_session.id, customer_id: customer&.id)
    )

    filter_and_save_transaktions(transaktion)
  end

  def create_item_transfer
    warehouse = Warehouse.find(params[:warehouse_id])

    if warehouse
      save_and_create_item_transfer(warehouse)
    else
      render 'pos_session/item_transfer'
    end
  end

  def item_transactions_session
    if params[:unit_total].present? && params[:sales] == 'true'
      session[:item_transactions_sales] << JSON.parse(item_transaktions_params.to_json)
      turbo_frame_id, partial_transaktion, session_item_transaktions = set_data_item_transaktions('Sales')
    elsif params[:unit_total].present? && params[:item_transfer] == 'true'
      session[:item_transactions_transfer] << JSON.parse(item_transaktions_params.to_json)
      turbo_frame_id, partial_transaktion, session_item_transaktions = set_data_item_transaktions('Transfer')
    elsif params[:unit_total].present? && params[:market_rates] == 'true'
      session[:item_transactions_market_rates] << JSON.parse(item_transaktions_params.to_json)
      turbo_frame_id, partial_transaktion, session_item_transaktions = set_data_item_transaktions('Market rates')
    else
      create_and_save_item(params[:product_id])
      turbo_frame_id, partial_transaktion, session_item_transaktions = set_data_item_transaktions('Purchases')
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          turbo_frame_id,
          partial: partial_transaktion,
          locals: { item_transactions: session_item_transaktions }
        )
      end
    end
  end

  def modal_create_product
    @item = Item.new
    @warehouse = Warehouse.find(@pos_session.warehouse_id)
  end

  def modal_confirm_market_rates
    @payment_methods = ['Efectivo', 'Pago QR', 'Tarjeta', 'Transferencia']
  end

  def modal_confirm_transfer; end

  def delete_session
    item_id = params[:id].to_i
    array = []

    if params[:sales] == 'true'
      array = session[:item_transactions_sales]
      turbo_frame_id, partial_transaktion, session_item_transaktions = set_data_item_transaktions('Sales')
    elsif params[:transfer] == 'true'
      array = session[:item_transactions_transfer]
      turbo_frame_id, partial_transaktion, session_item_transaktions = set_data_item_transaktions('Transfer')
    elsif params[:market_rates] == 'true'
      array = session[:item_transactions_market_rates]
      turbo_frame_id, partial_transaktion, session_item_transaktions = set_data_item_transaktions('Market rates')
    elsif params[:purchase] == 'true'
      array = session[:item_transactions_purchase]
      turbo_frame_id, partial_transaktion, session_item_transaktions = set_data_item_transaktions('Purchases')
    end

    array.delete_if { |hash| hash['item_id'].to_i == item_id }
    session[turbo_frame_id] = array

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          turbo_frame_id,
          partial: partial_transaktion,
          locals: { item_transactions: session_item_transaktions }
        )
      end
    end
  end

  def delete_all_session
    if params[:sales] == 'true'
      session[:item_transactions_sales] = []
      turbo_frame_id, partial_transaktion, session_item_transaktions = set_data_item_transaktions('Sales')
    elsif params[:transfer] == 'true'
      session[:item_transactions_transfer] = []
      turbo_frame_id, partial_transaktion, session_item_transaktions = set_data_item_transaktions('Transfer')
    elsif params[:market_rates] == 'true'
      session[:item_transactions_market_rates] = []
      turbo_frame_id, partial_transaktion, session_item_transaktions = set_data_item_transaktions('Market rates')
    elsif params[:purchase] == 'true'
      session[:item_transactions_purchase] = []
      turbo_frame_id, partial_transaktion, session_item_transaktions = set_data_item_transaktions('Purchases')
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          turbo_frame_id,
          partial: partial_transaktion,
          locals: { item_transactions: session_item_transaktions }
        )
      end
    end
  end

  private

  def type_transaktions_params
    params.permit(
      :total, :type_transaktion, :description, :payment_method, :money_received,
      :money_returned
    )
  end

  def item_transaktions_params
    params.permit(:qty_unit, :qty_package, :sub_total, :item_id, :unit_total)
  end

  def set_pos_session
    @pos_session = PosSession.find(params[:pos_session_id])
    authorize @pos_session
  end

  def create_and_save_item(product_id)
    product = Product.find_by(id: product_id, account_id: current_account.id)
    item = Item.find_by(product_id: product.id, warehouse_id: @pos_session.warehouse_id, status: 0) if product

    if product && !item
      item = Item.create(
        product_id: product.id, quantity: 0, warehouse_id: @pos_session.warehouse_id,
        description: "#{product.description} #{product.presentation}", code: product.code,
        total_stock: 0
      )
      session[:item_transactions_purchase] << JSON.parse(
        item_transaktions_params.merge(item_id: item.id).to_json
      )
    else
      session[:item_transactions_purchase] << JSON.parse(
        item_transaktions_params.to_json
      )
    end
  end

  def filter_search_purchase(search, customer_id)
    items = []
    products = []
    if search.present?
      products = Product.where('LOWER(name) LIKE :query OR LOWER(description) LIKE :query OR LOWER(generic_name) LIKE :query OR LOWER(characteristics) LIKE :query OR LOWER(code) LIKE :query', query: "%#{search.downcase}%")
                        .where(account_id: current_account.id, status: 0).limit(30)
      items = Item.where(product: products.map(&:id), warehouse_id: @pos_session.warehouse_id, status: 0).limit(30)
    end

    if customer_id.present?
      products = products.where(customer_id: customer_id) unless products.empty?
      items = items.where(product: products.map(&:id)) unless items.empty?
    end

    items
  end

  def filter_search_sale
    return [] unless params[:search_product].present?

    products = Product.where(
      'LOWER(name) LIKE :query OR LOWER(description) LIKE :query OR LOWER(generic_name) LIKE :query OR LOWER(characteristics) LIKE :query OR LOWER(code) LIKE :query',
      query: "%#{params[:search_product].downcase}%"
    ).where(account_id: current_account.id, status: 0)

    filter_result_search_product_sale(products)
  end

  def search_customers_filters
    return [] unless params[:search_provider].present?

    if params[:type_customer] == 'Proveedor' || params[:purchase_customer] == 'true'
      customer = Customer.where(
        'LOWER(document_number) LIKE :query',
        query: "%#{params[:search_provider].downcase}%"
      ).where(account_id: current_account.id, status: 0, type: 'Provider')
    elsif params[:purchase_customer_collector] == 'true'
      customer = Customer.where(
        'LOWER(document_number) LIKE :query',
        query: "%#{params[:search_provider].downcase}%"
      ).where(account_id: current_account.id, status: 0, type: 'Collector')
    else
      customer = Customer.where(
        'LOWER(document_number) LIKE :query',
        query: "%#{params[:search_provider].downcase}%"
      ).where(account_id: current_account.id, status: 0, type: 'Buyer')
    end

    customer.any? ? customer : []
  end

  def set_data_search_product_sale
    if params[:transfer].present?
      ['search_results_transfer', 'search_transaktions/search_results_transfer']
    elsif params[:market_rates].present?
      ['search_results_market_rates', 'search_transaktions/search_results_market_rates']
    else
      ['search_results_sales', 'search_transaktions/search_results_sales']
    end
  end

  def set_data_item_transaktions(type_transaktion)
    case type_transaktion
    when 'Purchases'
      [
        'item_transactions_purchase',
        'shared/tables/table_items_added_purchases',
        session[:item_transactions_purchase]
      ]
    when 'Market rates'
      [
        'item_transactions_market_rates',
        'shared/tables/table_items_added_market_rates',
        session[:item_transactions_market_rates]
      ]
    when 'Transfer'
      [
        'item_transactions_transfer',
        'shared/tables/table_items_added_transfer',
        session[:item_transactions_transfer]
      ]
    when 'Sales'
      [
        'item_transactions_sales',
        'shared/tables/table_items_added_sales',
        session[:item_transactions_sales]
      ]
    end
  end

  def filter_result_search_product_sale(products)
    if params[:search_in_warehouse_the_session] == 'true'
      Item.where(
        warehouse_id: @pos_session.warehouse_id,
        product: products.map(&:id), status: 0
      ).where.not(total_stock: 0).limit(30)
    elsif params[:search_in_other_warehouse] == 'true'
      warehouses_filters = current_account.warehouses.reject do |obj|
        obj.id == @pos_session.warehouse_id
      end
      Item.where(
        product: products.map(&:id), status: 0, warehouse: warehouses_filters
      ).limit(30)
    else
      []
    end
  end

  def save_type_transaktion(transaktion, item_transactions, notice_message)
    transaktion.save
    item_transactions.each do |obj|
      ItemTransaction.create(
        item_id: obj['item_id'], transaktion_id: transaktion.id,
        qty: obj['unit_total'], sub_total: obj['sub_total']
      )
    end
    if transaktion.type_transaktion == 'Sales'
      session[:item_transactions_sales] = []
      redirect_to pos_session_sales_path(@pos_session), notice: notice_message
    elsif transaktion.type_transaktion == 'Market rates'
      session[:item_transactions_market_rates] = []
      redirect_to pos_session_path(@pos_session), notice: notice_message
    end
  end

  def save_and_create_item_transfer(warehouse)
    transaktion = @pos_session.transaktions.build(
      type_transaktions_params.merge(
        destination_warehouse_id: warehouse.id, status: 'sent', payment_method: 'Transfer'
      )
    )

    if transaktion.save
      session[:item_transactions_transfer].each do |obj|
        transaktion.item_transactions.create(
          item_id: obj['item_id'], qty: obj['unit_total'], sub_total: obj['sub_total']
        )
      end
      session[:item_transactions_transfer] = []
      notice_message = 'Traspaso de Productos enviado con exito!'
      redirect_to pos_session_path(@pos_session), notice: notice_message
    else
      render 'transaktions/item_transfer', status: :unprocessable_entity
    end
  end

  def search_warehouse_filters
    if params[:search_warehouse].present?
      warehouses = Warehouse.joins(:warehouse_detail).where(
        'LOWER(warehouses.name) LIKE :query OR LOWER(warehouse_details.address) LIKE :query OR LOWER(warehouse_details.nit) LIKE :query OR LOWER(warehouse_details.branch_code) LIKE :query',
        query: "%#{params[:search_warehouse].downcase}%"
      ).where(account_id: current_account.id, status: 0).limit(30).reject { |obj| obj.id == @pos_session.warehouse_id }

      warehouses.empty? ? [] : warehouses
    else
      []
    end
  end

  def filter_and_save_transaktions(transaktion)
    case transaktion.type_transaktion
    when 'Sales'
      if transaktion.valid?
        notice_message = 'Venta realizada con exito!'
        save_type_transaktion(transaktion, session[:item_transactions_sales], notice_message)
      else
        render 'transaktions/sales', status: :unprocessable_entity
      end
    when 'Market rates'
      if transaktion.valid?
        transaktion.status = 'valued'
        notice_message = 'Cotización realizada con exito!'
        save_type_transaktion(transaktion, session[:item_transactions_market_rates], notice_message)
      else
        render 'transaktions/market_rates', status: :unprocessable_entity
      end
    end
  end

  def search_transaktions_filter
    query_customer = 'OR LOWER(customers.name) LIKE :query OR LOWER(customers.document_number) LIKE :query'
    transaktions = Transaktion.joins(:customer).where(
      "LOWER(transaktions.id) LIKE :query OR LOWER(transaktions.code) LIKE :query OR LOWER(transaktions.type_transaktion) LIKE :query #{query_customer}",
      query: "%#{params[:search_transaktions].downcase}%"
    ).where(pos_session_id: params[:pos_session_id]).limit(30)

    transaktions
  end
end
