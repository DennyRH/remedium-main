class PosSessionsController < ApplicationController
  before_action :set_pos_session, only: %i[show edit update destroy]
  before_action :set_breadcrumbs_pos_session, only: %i[index new edit show]
  before_action :skip_authorization, only: :search_pos_sessions

  def index
    @filter_pos_sessions = set_filter_pos_sessions
    if params[:type_filter].present?
      @pos_sessions = policy_scope(PosSession).where(
        status: params[:type_filter]
      ).page(params[:page]).per(15).order(id: :desc)
    else
      @pos_sessions = policy_scope(PosSession).page(params[:page]).per(15).order(id: :desc)
    end
    authorize @pos_sessions
    @pos_session_active = PosSession.find_by(user_id: current_user.id, status: 'active')
    @pos_session_pending = PosSession.find_by(user_id: current_user.id, status: 'validating')
    redirect_to pos_session_path(@pos_session_active) if @pos_session_active
    redirect_to pos_session_path(@pos_session_pending) if @pos_session_pending
  end

  def search_pos_sessions
    @pos_sessions = search_pos_sessions_filter

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          'search_results_pos_sessions_index',
          partial: 'shared/tables/table_pos_session',
          locals: { pos_sessions: @pos_sessions }
        )
      end
    end
  end

  def new
    @pos_session = PosSession.new
    @warehouse_ids = set_access_allowed_warehouse_ids
    authorize @pos_session
  end

  def create
    @pos_session = PosSession.new(pos_session_params)
    @warehouse_ids = set_access_allowed_warehouse_ids
    @pos_session.user_id = current_user.id
    authorize @pos_session

    if @pos_session.valid?
      @pos_session.save
      redirect_to pos_session_path(@pos_session), notice: 'Se Abrio una nueva Caja con exito!'
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def show
    @sale_transaktions = @pos_session.transaktions.where(
      type_transaktion: 'Sales'
    ).page(params[:page]).per(20)

    @income_annullated = Transaktion.where(
      type_transaktion: ['Sales', 'Market rates'], status: 'annulled',
      receiver_pos_session_id: @pos_session.id
    ).map(&:total).sum

    @expenses_annullated = Transaktion.where(
      type_transaktion: ['Purchases', 'Purchases Credit'], status: 'annulled',
      receiver_pos_session_id: @pos_session.id
    ).map(&:total).sum

    if @pos_session.total_payment_methods
      @total_payment_methods = JSON.parse(@pos_session.total_payment_methods)
    end
  end

  def edit
    @arching_ticketings = set_arching_ticketing
  end

  def update
    update_pos_session(@pos_session) unless @pos_session.status == 'validating'
    closed_pos_session_forced(@pos_session)
    arching_closed_message = 'Arqueo finalizado, Se cerro la Caja correctamente.' if @pos_session.closed?

    if @pos_session.update(pos_session_params)
      redirect_to pos_session_path(@pos_session), notice: arching_closed_message
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    if @pos_session.update(status: 1)
      redirect_to pos_sessions_path
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  private

  def pos_session_params
    params.require(:pos_session).permit(
      :id, :warehouse_id, :petty_cash, :type_of_currency, :status, :observation,
      :total_balance, :initial_balance, :missing_money, :remaining_money,
      :total_session, :user_id, :total_income, :total_expenses
    )
  end

  def set_pos_session
    @pos_session = PosSession.find(params[:id])
    authorize @pos_session
  end

  def update_pos_session(pos_session)
    purchase_credit_confirms = Transaktion.where(
      type_transaktion: 'Purchases Credit', status: 'active',
      receiver_pos_session_id: pos_session.id
    )

    total_income = 0
    total_expenses = 0

    if purchase_credit_confirms.any?
      purchase_credit_confirms.each do |obj|
        total_expenses += obj.total
      end
    end

    pos_session.transaktions.each do |obj|
      if obj.type_transaktion == 'Purchases' && obj.status == 'active'
        total_expenses += obj.total
      elsif obj.type_transaktion == 'Sales' && obj.status == 'active'
        total_income += obj.total
      elsif obj.type_transaktion == 'Market rates' && obj.status == 'active'
        total_income += obj.total
      end
    end

    total_session = (pos_session.petty_cash + total_income - total_expenses).round(2)

    operation_result = (
      pos_session_params[:total_balance].to_f.round(2) - total_session.abs
    ).round(2)

    missing_money = operation_result <= 0 ? operation_result.abs : 0
    remaining_money = operation_result >= 0 ? operation_result : 0

    pos_session.total_balance = pos_session_params[:total_balance]
    pos_session.missing_money = missing_money
    pos_session.remaining_money = remaining_money
    pos_session.total_income = total_income.round(2)
    pos_session.total_expenses = total_expenses.round(2)
    pos_session.total_session = total_session.negative? ? 0 : total_session
    pos_session.status = 'validating' if pos_session.status == 'active'
    pos_session.status = 'closed' if pos_session.total_balance >= pos_session.total_session
    set_total_payment_methods(@pos_session)
  end

  def set_total_payment_methods(pos_session)
    total_income_qr = set_total_income_transaktion(pos_session, 'Pago QR')
    total_expenses_qr = set_total_expenses_transaktion(pos_session, 'Pago QR', 'Purchases')
    total_expenses_qr_credit = set_total_expenses_transaktion(pos_session, 'Pago QR', 'Purchases Credit')

    total_income_ca = set_total_income_transaktion(pos_session, 'Tarjeta')
    total_expenses_ca = set_total_expenses_transaktion(pos_session, 'Tarjeta', 'Purchases')
    total_expenses_ca_credit = set_total_expenses_transaktion(pos_session, 'Tarjeta', 'Purchases Credit')

    total_income_tr = set_total_income_transaktion(pos_session, 'Transferencia')
    total_expenses_tr = set_total_expenses_transaktion(pos_session, 'Transferencia', 'Purchases')
    total_expenses_tr_credit = set_total_expenses_transaktion(pos_session, 'Transferencia', 'Purchases Credit')

    total_income_ef = set_total_income_transaktion(pos_session, 'Efectivo')
    total_expenses_ef = set_total_expenses_transaktion(pos_session, 'Efectivo', 'Purchases')
    total_expenses_ef_credit = set_total_expenses_transaktion(pos_session, 'Efectivo', 'Purchases Credit')

    total_payment_methods_json = {
      total_arching_money: JSON.parse(params[:total_arching_money]),
      income: {
        qr: { total: total_income_qr.round(2) },
        cash: { total: total_income_ef.round(2) },
        card: { total: total_income_ca.round(2) },
        transfer: { total: total_income_tr.round(2) }
      },
      expenses: {
        qr: { total: (total_expenses_qr + total_expenses_qr_credit).round(2) },
        cash: { total: (total_expenses_ef + total_expenses_ef_credit).round(2) },
        card: { total: (total_expenses_ca + total_expenses_ca_credit).round(2) },
        transfer: { total: (total_expenses_tr + total_expenses_tr_credit).round(2) }
      }
    }.to_json

    pos_session.total_payment_methods = total_payment_methods_json
  end

  def closed_pos_session_forced(pos_session)
    if pos_session.status == 'validating' && params[:arching_forced] == 'true'
      pos_session.update(status: 'closed')
    end
  end

  def set_access_allowed_warehouse_ids
    access_alloweds = []
    access_alloweds_user = AccessAllowed.where(user_id: current_user.id).order(warehouse_id: :asc)
    access_alloweds_user.each do |access|
      access_alloweds << [
        "#{access.warehouse.name} (#{access.warehouse&.warehouse_detail&.branch_code})",
        access.warehouse_id
      ]
    end
    access_alloweds
  end

  def set_arching_ticketing
    [
      { action_target: 'value200',  value_target: 'doscientos', img: '200bs.jpg' },
      { action_target: 'value100',  value_target: 'cien', img: '100bs.jpg' },
      { action_target: 'value50',  value_target: 'cincuenta', img: '50bs.jpg' },
      { action_target: 'value20',  value_target: 'veinte', img: '20bs.jpg' },
      { action_target: 'value10',  value_target: 'diez', img: '10bs.jpg' },
      { action_target: 'value5',  value_target: 'cinco', img: '5bs.png' },
      { action_target: 'value2',  value_target: 'dos', img: '2bs.jpg' },
      { action_target: 'value1',  value_target: 'uno', img: '1bs.jpg' },
      { action_target: 'value050',  value_target: 'cerocincuenta', img: '50ctvs.jpeg' },
      { action_target: 'value020',  value_target: 'ceroveinte', img: '20ctvs.jpg' },
      { action_target: 'value010',  value_target: 'cerodiez', img: '10ctvs.jpg' }
    ]
  end

  def set_breadcrumbs_pos_session
    add_breadcrumb 'Cajas', :pos_sessions_path
    add_breadcrumb @pos_session.warehouse.name, :pos_session_path if @pos_session
    add_breadcrumb 'Abrir Caja', :new_pos_session_path if action_name == 'new'
    add_breadcrumb 'Billetaje', :edit_pos_session_path if action_name == 'edit'
  end

  def search_pos_sessions_filter
    PosSession.joins('INNER JOIN users ON pos_sessions.user_id = users.id')
              .joins('INNER JOIN warehouses ON pos_sessions.warehouse_id = warehouses.id')
              .joins('INNER JOIN roles ON users.role_id = roles.id')
              .where(
                'LOWER(roles.name) LIKE :query OR LOWER(users.name) LIKE :query OR LOWER(users.last_name) LIKE :query OR LOWER(warehouses.name) LIKE :query OR LOWER(users.email) LIKE :query',
                query: "%#{params[:search_pos_sessions].downcase}%"
              ).where(warehouse_id: current_account.warehouses.map(&:id)).limit(30)
  end

  def set_filter_pos_sessions
    [
      ['Caja Activa', 'active'], ['Caja Cerrada', 'closed'], ['Caja Arqueando', 'validating']
    ]
  end

  def set_total_expenses_transaktion(session, payment_method, type_transaktion)
    if type_transaktion == 'Purchases Credit'
      Transaktion.where(
        payment_method: payment_method, type_transaktion: 'Purchases Credit', status: 'active',
        receiver_pos_session_id: session.id
      ).map(&:total).sum
    else
      session.transaktions.where(
        payment_method: payment_method, type_transaktion: 'Purchases', status: 'active'
      ).map(&:total).sum.to_f
    end
  end

  def set_total_income_transaktion(session, payment_method)
    session.transaktions.where(
      payment_method: payment_method, type_transaktion: ['Sales', 'Market rates'],
      status: 'active'
    ).map(&:total).sum.to_f
  end
end
