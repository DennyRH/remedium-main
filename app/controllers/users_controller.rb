class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy]
  before_action :set_breadcrumbs_user, only: %i[index new show edit create]
  before_action :skip_authorization, only: :search_users

  def index
    @filter_users = set_filter_users
    if params[:type_filter].present?
      @users = policy_scope(User).where(
        role_id: params[:type_filter].to_i
      ).page(params[:page]).per(12).order(id: :desc)
    else
      @users = policy_scope(User).page(params[:page]).per(12).order(id: :desc)
    end
    authorize @users
  end

  def search_users
    @users = search_users_filter

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          'search_results_users_index',
          partial: 'shared/cards/card_user',
          locals: { users: @users }
        )
      end
    end
  end

  def new
    @rol_ids = set_roles
    @user = User.new
    authorize @user
  end

  def create
    @rol_ids = set_roles
    @user = User.new(user_params)
    @user.account_id = current_account&.id
    authorize @user
    notice_message = "Se creo el usuario #{@user.name} #{@user.last_name}, con exito!"

    if @user.save
      redirect_to users_admin_path(@user), notice: notice_message
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def show
    @access_alloweds = AccessAllowed.where(user_id: @user.id)
  end

  def edit
    @rol_ids = set_roles
  end

  def update
    @rol_ids = set_roles

    if @user.update(user_params)
      notice_message = "Se Actualizo el usuario #{@user.name} #{@user.last_name}, con exito!"
      redirect_to users_admin_path(@user), notice: notice_message
    else
      @rol_ids = set_roles
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    @rol_ids = set_roles
    notice_message = "Se Elimino el usuario #{@user.name} #{@user.last_name}, con exito!"

    if @user.update(status: 1)
      redirect_to users_admin_index_path, notice: notice_message
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :name, :last_name, :password, :ci, :role_id)
  end

  def set_user
    @user = User.find(params[:id])
    authorize @user
  end

  def set_roles
    rol_ids = [['Propietario', 1], ['Administrador', 2], ['Vendedor', 3]]
    rol_ids_account = Role.where(account_id: current_account&.id)
    rol_ids_account.each { |role| rol_ids << [role.name, role.id] }
    rol_ids
  end

  def set_filter_users
    roles = Role.where(account_id: [0, current_account.id])
    roles.map { |rol| [rol.name_es || rol.name, rol.id] }
  end

  def set_breadcrumbs_user
    add_breadcrumb 'Usuarios', :users_admin_index_path
    add_breadcrumb 'Crear', :new_users_admin_path if ['new', 'create'].include?(action_name)
    add_breadcrumb @user.name, :users_admin_path if @user
    add_breadcrumb 'Editar', edit_users_admin_path(@user) if ['edit', 'update'].include?(action_name)
  end

  def search_users_filter
    User.joins(:role).where(
      'LOWER(users.id) LIKE :query OR LOWER(users.name) LIKE :query OR LOWER(users.last_name) LIKE :query OR LOWER(users.email) LIKE :query OR LOWER(roles.name) LIKE :query',
      query: "%#{params[:search_users].downcase}%"
    ).where(account_id: current_user.account_id).limit(30)
  end
end
