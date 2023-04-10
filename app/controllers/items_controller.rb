class ItemsController < ApplicationController
  before_action :set_warehouse
  before_action :set_item, only: %i[show edit update destroy set_breadcrumbs_customers]
  before_action :set_breadcrumbs_customers, only: %i[index new edit show]
  require 'prawn/table'
  require 'prawn'

  def index
    @items = policy_scope(Item).where(
      warehouse_id: params[:warehouse_id], status: 0
    ).page(params[:page]).per(15).order(id: :desc)
    authorize @items
  end


  def search_items
    @items = search_items_filter

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          'search_results_items_index',
          partial: 'shared/tables/table_item',
          locals: { items: @items }
        )
      end
    end
  end

  def new
    @item = Item.new
    authorize @item
  end

  def create
    @item = Item.new(item_params)
    @item.warehouse_id = params[:warehouse_id]
    authorize @item
    notice_message = "Se creo el item del producto: #{@item.product.name}, con exito!"

    if @item.valid?
      save_and_create_item(@item, notice_message)
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def show
    start_date = Date.parse(params[:start_date]) if params[:start_date].present?
    end_date = Date.parse(params[:end_date]) if params[:end_date].present?

    if start_date.present? && !end_date.present?
      between_date_filter = start_date.beginning_of_day..Time.now
    elsif !start_date.present? && end_date.present?
      between_date_filter = @item.created_at..end_date.end_of_day
    elsif start_date.present? && end_date.present?
      between_date_filter = start_date.beginning_of_day..end_date.end_of_day
    else
      between_date_filter = @item.created_at..Time.now
    end

    @item_transaktions = ItemTransaction.joins(:transaktion).where(
      transaktions: { status: %w[active annulled], created_at: between_date_filter },
      item_transactions: { item_id: @item.id }
    ).page(params[:page]).per(30).order(id: :desc)
  end

  def edit; end

  def update
    notice_message = "Se Actualizo el item del producto: #{@item.product.name}, con exito!"

    case params[:warehouse_edit_context]
    when 'Current Warehouse' then update_one_item(@item, notice_message)
    when 'All Warehouses' then update_all_item(@item)
    end
  end

  def destroy
    notice_message = "Se Elimino el item del producto: #{@item.product.name}, con exito!"

    if @item.update(status: 1)
      redirect_to warehouse_items_path(@warehouse), notice: notice_message
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def search_product
    @products = search_product_filters

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          'search_results_product_reference',
          partial: 'shared/searchs/search_results_products',
          locals: { products: @products }
        )
      end
    end
  end

  def download_pdf
    @items = index_action

    data = data_table
    fecha_hora = Time.now.strftime("%d/%m/%Y  %H:%M:%S")
    texto_encabezado = "Inventario Fisico: #{@warehouse.name}"
    pdf = Prawn::Document.new(page_layout: :portrait)

    # Define el estilo de la tabla
    pdf.font_size 8
    pdf.font "Helvetica"

    pdf.text_box texto_encabezado, at: [0, pdf.cursor], size: 16, align: :left, leading: 15
    pdf.text_box fecha_hora, at: [pdf.bounds.width - 150, pdf.cursor], size: 12, align: :right, leading: 15
    pdf.move_down 20
    # Crea la tabla
    pdf.table data, cell_style: { border_width: 0, border_style: :solid }, row_colors: ["FFFFFF", "EEEEEE"]  do |t|
      # Define el estilo de las celdas de la primera fila (los encabezados de la tabla)
      t.header = true
      t.row(0).font_style = :bold
      t.row(0).background_color = "DDDDDD"
      t.column_widths = {0 => 68, 1 => 97, 2 => 240, 3 => 45, 4 => 45, 5 => 45}
    end

    opciones_paginas = {
      at: [pdf.bounds.right - 50, 0],
      width: 50,
      align: :right,
      start_count_at: 1,
      size: 12
    }
    pdf.number_pages "<page>/<total>", opciones_paginas

    pdf.render_file "tabla.pdf"
    send_data(pdf.render, type: "application/pdf", disposition: "attatchment")
  end

  def preview_pdf
    @items = index_action
    data = data_table

    fecha_hora = Time.now.strftime("%d/%m/%Y %H:%M:%S")
    texto_encabezado = "Inventario Fisico: #{@warehouse.name}"

    pdf = Prawn::Document.new(page_layout: :portrait, page_size: "A4", margin: [20, 10] )
    pdf.font_size 8
    pdf.font "Helvetica"

    pdf.text_box texto_encabezado, at: [0, pdf.bounds.height], size: 16, align: :left, leading: 15
    pdf.text_box fecha_hora, at: [pdf.bounds.width - 150, pdf.bounds.height], size: 12, align: :right, leading: 15
    pdf.move_down(30)

    pdf.table data, cell_style: { border_width: 0, border_style: :solid}, row_colors: ["FFFFFF", "EEEEEE"] do |t|
      t.header = true
      t.row(0).font_style = :bold
      t.row(0).background_color = "DDDDDD"
      t.column_widths = {0 => 50, 1 => 68, 2 => 97, 3 => 225, 4 => 45, 5 => 45, 6 => 45}
    end

    opciones_footer = {
      at: [pdf.bounds.right - 50, 15],
      width: 50,
      align: :right,
      start_count_at: 1,
      size: 12
    }


    pdf.repeat :all do
      pdf.text_box texto_encabezado, at: [pdf.bounds.left, pdf.bounds.bottom + 15], size: 12
      pdf.text_box fecha_hora, at: [pdf.bounds.left, pdf.bounds.bottom + 15], width: pdf.bounds.width, align: :center, size: 12
    end
    pdf.number_pages "pag. <page>/<total>" , opciones_footer

    pdf.render_file "tabla.pdf"
    send_data(pdf.render, type: "application/pdf", disposition: "inline")
  end

  def index_action
    @items = policy_scope(Item).where(warehouse_id: params[:warehouse_id], status: 0)
    authorize @items
  end

  def get_valid_code(code, import_id, alternative_code)
    [code, import_id, alternative_code].find { |c| c.present? && c != 0 } || 0
  end

  def data_table
    @items = index_action
    grouped_items = @items.group_by { |item| item.product&.customer&.name }
    @sorted_items = []
    @sorted_items << ["Proveedor", "Código", "Nombre Genérico", "Descripción",  "Total Stock", "Total Paq.", "Min. Stock" ]
    grouped_items.keys.sort.each do |key|
      items = grouped_items[key]
      items.each do |item|
        @sorted_items << [item.product&.customer&.name, get_valid_code(item.product&.code, item.product&.import_id, item.product&.alternative_code),
          item.product&.generic_name, item.product&.description, item.total_stock, item.quantity, item.min_stock]
      end
    end

    return data = @sorted_items
  end

  def new_data

  end

  private

  def item_params
    params.require(:item).permit(
      :id, :warehouse_id, :quantity, :description, :code, :expiration_date,
      :date_of_elaboration, :total_stock, :min_stock, :max_stock, :status,
      :product_id, :sale_price_package, :sale_price_unit, :purchase_cost_package,
      :purchase_cost_unit, :list_price
    )
  end

  def set_warehouse
    @warehouse = Warehouse.find(params[:warehouse_id])
    authorize @warehouse
  end

  def set_item
    @item = Item.find(params[:id])
    authorize @item
  end

  def save_and_create_item(item, notice_message)
    item.save
    pos_session = PosSession.find_by(
      user_id: current_user.id, status: 'active', warehouse_id: item.warehouse_id
    )
    if pos_session
      redirect_to pos_session_purchases_path(pos_session), notice: notice_message
    else
      redirect_to warehouse_item_path(@warehouse, item), notice: notice_message
    end
  end

  def search_product_filters
    if params[:search_product].present?
      products = Product.where(
        'LOWER(name) LIKE :query OR LOWER(generic_name) LIKE :query OR LOWER(description) LIKE :query OR LOWER(code) LIKE :query',
        query: "%#{params[:search_product].downcase}%"
      ).where(account_id: current_account.id, status: 0).limit(30)

      products.any? ? products : []
    else
      []
    end
  end

  def update_one_item(item, notice_message)
    if item.update(item_params)
      redirect_to warehouse_item_path(@warehouse, item), notice: notice_message
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def update_all_item(item)
    notice_message = "Se Actualizo el item del producto: #{item.product.name}, en todas las sucursales con exito!"
    warehouses = Warehouse.where(account_id: current_account.id, status: 0)
    items = Item.where(warehouse: warehouses, product_id: item.product_id, status: 0)
    items.each do |obj|
      obj.update(
        purchase_cost_package: item_params[:purchase_cost_package],
        sale_price_package: item_params[:sale_price_package],
        purchase_cost_unit: item_params[:purchase_cost_unit],
        sale_price_unit: item_params[:sale_price_unit],
        list_price: item_params[:list_price]
      )
    end
    redirect_to warehouse_item_path(@warehouse, item), notice: notice_message
  end

  def set_breadcrumbs_customers
    add_breadcrumb 'Sucursales', warehouses_path(@warehouse)
    add_breadcrumb @warehouse.name, warehouse_path(@warehouse)
    add_breadcrumb 'Inventario', warehouse_items_path(@warehouse)
    add_breadcrumb @item.product.name, warehouse_item_path(@warehouse, @item) if @item
    add_breadcrumb 'Crear', new_warehouse_item_path(@warehouse) if action_name == 'new'
    add_breadcrumb 'Editar', edit_warehouse_item_path(@warehouse, @item) if action_name == 'edit'
  end

  def search_items_filter
    Item.joins(:product).where(
      'LOWER(items.id) LIKE :query OR LOWER(products.name) LIKE :query OR LOWER(products.code) LIKE :query OR LOWER(products.generic_name) LIKE :query OR LOWER(products.description) LIKE :query',
      query: "%#{params[:search_items].downcase}%"
    ).where(warehouse_id: params[:warehouse_id], status: 0).limit(30)
  end
end
