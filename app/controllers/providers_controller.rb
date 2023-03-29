class ProvidersController < ApplicationController
  before_action :set_provider, only: %i[show edit update destroy]
  before_action :set_breadcrumbs_providers
  before_action :skip_authorization, only: %i[search searches]

  def index
    @providers = policy_scope(Customer).where(type: 'Provider', status: 'active').page(params[:page]).per(15).order(id: :desc)
    authorize @providers
  end

  def show
  end

  def new
    @provider = Provider.new
    authorize @provider
  end

  def create
    @provider = Provider.new(provider_params)
    @provider.account_id = current_account.id
    authorize @provider
    pos_session_active = PosSession.find_by(status: 'active', user_id: current_user.id)
    if @provider.valid?
      @provider.save
      notice_message = "Creado exitosamente"
      respond_to do |format|
        format.json { render json: @provider.to_json }
        format.html {
          redirect_to pos_session_active ? pos_session_purchases_path(pos_session_active) : provider_path(@provider),
          notice: notice_message
        }
      end
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @provider.update(provider_params)
      notice_message = "Actualizado exitosamente"
      redirect_to provider_path(@provider), notice: notice_message
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    notice_message = "Eliminado exitosamente"

    if @provider.deleted!
      redirect_to providers_path, notice: notice_message
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def searches
    turbo_frame_id = "search_results_providers_index"
    partial_path = set_provider_partial
    @providers = search_providers
    respond_to do |format|
      format.json { render json: @providers.to_json }
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          turbo_frame_id,
          partial: partial_path,
          locals: { customers: @providers, kind: 'provider' }
        )
      end
    end
  end

  def search
    @provider = search_provider
    respond_to do |format|
      format.json { render json: @provider.to_json }
    end
  end
  
  def modal_new
    @provider = Provider.new
    @pos_session_active = PosSession.find_by(status: 'active', user_id: current_user.id)
    authorize @provider
  end

  private

  def provider_params
    params.require(:provider).permit(:id, :name, :email, :phone, :nit, :document_number)
  end

  def set_provider
    @provider = Provider.find(params[:id])
    authorize @provider
  end

  def set_breadcrumbs_providers
    add_breadcrumb 'Proveedores', :providers_path
    add_breadcrumb 'Crear', :new_provider_path if ['new', 'create'].include?(action_name)
    add_breadcrumb @provider.social_reason, :provider_path if @provider
    add_breadcrumb 'Editar', :edit_provider_path if ['edit', 'update'].include?(action_name)
  end

  def search_providers
    Provider.active.where(
      'LOWER(id) LIKE :query OR LOWER(email) LIKE :query OR LOWER(document_number) LIKE :query OR LOWER(name) LIKE :query',
      query: "%#{params[:filter].downcase}%"
    ).where(account_id: current_user.account_id).limit(30)
  end

  def search_provider
    Provider.find_by(account_id: current_account.id, nit: params[:filter], status: 'active')
  end

  def set_provider_partial
    params[:partial_path].present? ? params[:partial_path] : 'shared/tables/table_customers'
  end

  # def search_customer_product
  #   return unless params[:search_customers].present?

  #   if params[:search_provider] == 'true'
  #     Customer.find_by(
  #       'LOWER(ci) LIKE :query OR LOWER(nit) LIKE :query',
  #       query: "%#{params[:search_customers].downcase}%",
  #       account_id: current_account.id, status: 0, type_customer: 'Proveedor'
  #     )
  #   end
  # end
end
