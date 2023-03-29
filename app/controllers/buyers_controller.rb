class BuyersController < ApplicationController
  before_action :set_buyer, only: %i[show edit update destroy]
  before_action :set_breadcrumbs_buyers, only: %i[index show edit new create update]
  before_action :skip_authorization, only: %i[searches search]

  def index
    @buyers = policy_scope(Buyer).active.page(params[:page]).per(15).order(id: :desc)
    authorize @buyers
  end

  def new
    @buyer = Buyer.new
    authorize @buyer
  end

  def create
    @buyer = Buyer.new(**buyer_params, account_id: current_account.id)
    authorize @buyer
    if @buyer.save
      respond_to do |format|
        format.json { render json: @buyer.to_json }
        format.html {
          redirect_to buyer_path(@buyer),
          notice: "Creado exitosamente"
        }
      end
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def show; end
  def edit; end

  def update
    if @buyer.update(buyer_params)
      notice_message = "Actualizado exitosamente"
      redirect_to buyer_path(@buyer), notice: notice_message
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    if @buyer.update(status: 'deleted')
      redirect_to buyers_path, notice: "Eliminado exitosamente"
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def searches
    turbo_frame_id = "search_results_buyers_index"
    @buyers = search_buyers
    respond_to do |format|
      format.json { render json: @buyers.to_json }
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          turbo_frame_id,
          partial: 'shared/tables/table_customers',
          locals: { customers: @buyers, kind: 'buyer' }
        )
      end
    end
  end

  def search
    @buyer = search_buyer
    respond_to do |format|
      format.json { render json: @buyer.to_json }
    end
  end

  private

  def buyer_params
    params.require(:buyer).permit(:id, :name, :ci_or_nit, :document_number, :email, :phone)
  end

  def set_buyer
    @buyer = Buyer.find(params[:id])
    authorize @buyer
  end

  def set_breadcrumbs_buyers
    add_breadcrumb 'Clientes', :buyers_path
    add_breadcrumb 'Crear', :new_buyer_path if ['new', 'create'].include?(action_name)
    add_breadcrumb @buyer.name, :buyer_path if @buyer
    add_breadcrumb 'Editar', :edit_buyer_path if ['edit', 'update'].include?(action_name)
  end

  def search_buyers
    Buyer.active.where(
      'LOWER(id) LIKE :query OR LOWER(email) LIKE :query OR LOWER(document_number) LIKE :query OR LOWER(name) LIKE :query',
      query: "%#{params[:filter].downcase}%"
    ).where(account_id: current_account.id).limit(30)
  end

  def search_buyer
    Buyer.find_by(account_id: current_account.id, ci_or_nit: params[:filter], status: 'active')
  end
end
