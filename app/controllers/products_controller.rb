class ProductsController < ApplicationController
  before_action :set_product, only: %i[show edit update destroy]
  before_action :set_breadcrumbs_products, only: %i[index new edit show]
  before_action :skip_authorization, only: :search_products

  def index
    @products = policy_scope(Product).page(params[:page]).per(15).order(id: :desc)
    authorize @products
  end

  def search_products
    @products = search_products_filter

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          'search_results_products_index',
          partial: 'shared/tables/table_product',
          locals: { products: @products }
        )
      end
    end
  end

  def new
    @product = Product.new
    authorize @product
  end

  def create
    @pos_session = PosSession.find_by(user_id: current_user.id, status: 'active')
    @product = Product.new(product_params)
    @product.account_id = current_account.id
    authorize @product

    create_product(@product, @pos_session)
  end

  def show
    @warehouses_filter = current_account.warehouses.map { |obj| [obj.name, obj.id] }
    start_date = Date.parse(params[:start_date]) if params[:start_date].present?
    end_date = Date.parse(params[:end_date]) if params[:end_date].present?

    if start_date.present? && !end_date.present?
      between_date_filter = start_date.beginning_of_day..Time.now
    elsif !start_date.present? && end_date.present?
      between_date_filter = @product.created_at..end_date.end_of_day
    elsif start_date.present? && end_date.present?
      between_date_filter = start_date.beginning_of_day..end_date.end_of_day
    else
      between_date_filter = @product.created_at..Time.now
    end

    if params[:warehouse_filter].present?
      items = Item.where(product_id: @product.id, warehouse_id: params[:warehouse_filter])
    else
      items = Item.where(product_id: @product.id, warehouse_id: current_account.warehouses)
    end

    @item_transaktions = ItemTransaction.joins(:transaktion).where(
      transaktions: { status: %w[active annulled], created_at: between_date_filter },
      item_transactions: { item_id: items }
    ).page(params[:page]).per(30).order(id: :desc)
  end

  def edit; end

  def update
    set_provider_product_update

    if @product.update(product_params)
      notice_message = "Actualizado exitosamente"
      redirect_to product_path(@product), notice: notice_message
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    notice_message = "Se Elimino el producto '#{@product.name}', con exito!"

    if @product.update(status: 1)
      redirect_to products_path, notice: notice_message
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  private

  def product_params
    params.require(:product).permit(
      :id, :name, :description, :code, :presentation, :status, :trademark,
      :customer_id, :list_price, :generic_name, :unit, :package, :category,
      :sub_category, :total_unit, :model_rrss, :characteristics,
      :account_id, items_attributes: [
        :id, :warehouse_id, :quantity, :description, :code, :expiration_date,
        :date_of_elaboration, :total_stock, :min_stock, :max_stock, :status,
        :product_id, :sale_price_unit, :sale_price_package, :purchase_cost_package,
        :purchase_cost_unit
      ]
    )
  end

  def set_product
    @product = Product.find(params[:id])
    authorize @product
  end

  def create_product(product, pos_session)
    customer = Provider.find_by_id(params[:customer_id])

    if customer.nil? && params[:document_number].present? && params[:name].present?
      customer = Provider.create(
        document_number: params[:document_number], name: params[:name],
        account_id: current_account.id, email: params[:email]
      )
      product.customer_id = customer.id
    end

    if product.valid?
      product.save
      redirect_to product_path(product), notice: "Se creo el producto '#{product.name}', con exito!"
    elsif !product.valid? && pos_session
      render turbo_stream: turbo_stream.update(
        'create_product_from_purchase',
        partial: 'shared/forms/form_create_product',
        locals: { product: product, pos_session: pos_session }
      )
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def set_breadcrumbs_products
    add_breadcrumb 'Productos', :products_path
    add_breadcrumb @product.name, :product_path if @product
    add_breadcrumb 'Crear', :new_product_path if action_name == 'new'
    add_breadcrumb 'Editar', :edit_product_path if action_name == 'edit'
  end

  def search_products_filter
    Product.where(
      'LOWER(name) LIKE :query OR LOWER(description) LIKE :query OR LOWER(generic_name) LIKE :query OR LOWER(characteristics) LIKE :query OR LOWER(code) LIKE :query',
      query: "%#{params[:search_products].downcase}%"
    ).where(account_id: current_account.id).limit(30)
  end

  def set_provider_product_update
    customer = Provider.find_by_id(product_params[:customer_id])

    if customer.nil? && params[:document_number].present? && params[:name].present?
      customer = Customer.create(
        document_number: params[:document_number], name: params[:name],
        account_id: current_account.id, email: params[:email]
      )
      params[:product][:customer_id] = customer.id
    end
  end
end
