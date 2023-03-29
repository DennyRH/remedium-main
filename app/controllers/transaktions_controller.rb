class TransaktionsController < ApplicationController
  before_action :set_pos_session, except: %i[payment_center]
  before_action :set_payment_methods, only: %i[create sales update market_rates purchases paying]
  before_action :set_transaktion, only: %i[show edit update paying annullated]
  before_action :set_breadcrumbs_transaktions, only: %i[
    index show edit sales market_rates purchases item_transfer
  ]
  before_action :set_payment_breadcrumbs, only: %i[payment_center]

  def index
    @filter_transaktions = set_filter_transaktions
    if params[:type_filter].present?
      @transaktions = policy_scope(Transaktion).where(
        pos_session_id: params[:pos_session_id], type_transaktion: params[:type_filter]
      ).page(params[:page]).per(15).order(id: :desc)
    else
      @transaktions = policy_scope(Transaktion).where(
        pos_session_id: params[:pos_session_id]
      ).page(params[:page]).per(15).order(id: :desc)
    end
    authorize @transaktions
  end

  def create
    @transaktion = Transaktion.new(transaction_params)
    @transaktion.pos_session_id = @pos_session.id

    create_purchases(@transaktion)
  end

  def show
    @item_transactions = @transaktion.item_transactions.page(params[:page]).per(15).order(id: :desc)
    if @transaktion.annulled?
      @badge_type = 'danger'
    elsif @transaktion.active?
      @badge_type = 'success'
    else
      @badge_type = 'secondary'
    end
  end

  def edit; end

  def sales
    session[:item_transactions_sales] ||= []
    @sale = Transaktion.new
    @sale.build_customer
  end

  def market_rates
    session[:item_transactions_market_rates] ||= []
    @market_rate = Transaktion.new
    @market_rate.build_customer
  end

  def purchases
    session[:item_transactions_purchase] ||= []
    @purchase = Transaktion.new
  end

  def item_transfer
    session[:item_transactions_transfer] ||= []
  end

  def annullated
    @pos_sessions_active = PosSession.where(
      warehouse_id: @pos_session.warehouse_id, status: 'active'
    )
  end

  def paying
    @open_sessions = @pos_session&.warehouse&.pos_sessions&.active
  end

  def payment_center
    @pending_payments = Transaktion.where(
      type_transaktion: 'Purchases Credit', status: 'pending'
    ).page(params[:page]).per(20).order(id: :desc)
    @completed_payments = Transaktion.where(
      type_transaktion: 'Purchases Credit', status: 'active'
    ).page(params[:page]).per(20).order(id: :desc)
    authorize @pending_payments
  end

  def update
    @pending_payments = Transaktion.where(
      type_transaktion: 'Purchases Credit', status: 'pending'
    )
    case @transaktion.type_transaktion
    when 'Market rates' then update_market_rates(@transaktion)
    when 'Transfer' then update_transfer(@transaktion)
    when 'Purchases Credit' then update_purchase_credit(@transaktion, @payment_methods)
    end
    annullated_transaktion(@pos_session, @transaktion)
  end

  private

  def transaction_params
    params.require(:transaktion).permit(
      :id, :pos_session_id, :customer_id, :type_transaktion, :total, :status, :description,
      :money_received, :money_returned, :money_paid, :payment_method, :code, :discount,
      :date_of_payment, :receiver_pos_session_id, :destination_warehouse_id, :customer_received_money_id,
      :receipt_number, :invoice_number
    )
  end

  def transaktion_type_params
    params.require(:transaktion).permit(
      :id, :customer_id, :type_transaktion, :total, :status,
      :description, :money_received, :money_returned, :money_paid, :payment_method,
      :code, :discount, :receiver_pos_session_id, :destination_warehouse_id, :customer_received_money_id,
      :receipt_number, :invoice_number
    )
  end

  def set_pos_session
    @pos_session = PosSession.find(params[:pos_session_id])
    authorize @pos_session
  end

  def set_transaktion
    @transaktion = Transaktion.find(params[:id])
    authorize @transaktion
  end

  def set_breadcrumbs_transaktions
    add_breadcrumb 'Cajas', :pos_sessions_path
    add_breadcrumb @pos_session.warehouse.name, pos_session_path(@pos_session)
    add_breadcrumb 'Movimientos', pos_session_transaktions_path(@pos_session) if action_name == 'index' || @transaktion
    add_breadcrumb @transaktion.id, pos_session_transaktion_path(@pos_session, @transaktion) if @transaktion
    add_breadcrumb 'Compra', pos_session_purchases_path(@pos_session) if action_name == 'purchases'
    add_breadcrumb 'Venta', pos_session_sales_path(@pos_session) if action_name == 'sales'
    add_breadcrumb 'Cotización', pos_session_market_rates_path(@pos_session) if action_name == 'market_rates'
    add_breadcrumb 'Traspaso', pos_session_item_transfer_path(@pos_session) if action_name == 'item_transfer'
  end

  def set_payment_breadcrumbs
    add_breadcrumb 'Pagos', payment_center_path
  end

  def create_purchases(purchase)
    item = Item.find(session[:item_transactions_purchase][0]['item_id'])
    purchase.customer_id = item.product.customer_id
    notice_message = "#{purchase.type_transaktion_es} realizada con exito!"

    if purchase.type_transaktion == 'Purchases' && !purchase.customer_received_money_id
      collector = Customer.create(
        name: params[:name_collector], document_number: params[:ci_collector], account_id: current_account.id, type: "Collector"
      )
      purchase.customer_received_money_id = collector.id
    end

    if purchase.save
      session[:item_transactions_purchase].each do |obj|
        ItemTransaction.create(
          item_id: obj['item_id'], transaktion_id: purchase.id,
          qty: obj['unit_total'], sub_total: obj['sub_total']
        )
      end
      session[:item_transactions_purchase] = []
      redirect_to pos_session_path(@pos_session), notice: notice_message
    else
      render 'transaktions/purchases', status: :unprocessable_entity
    end
  end

  def update_market_rates(transaktion)
    transaktion.status = 'active'
    notice_message = 'Cotización confirmada con exito!'
    if transaktion.update(transaktion_type_params)
      redirect_to pos_session_path(@pos_session), notice: notice_message
    else
      render turbo_stream: turbo_stream.update(
        'confirm_market_rates',
        partial: 'shared/forms/form_confirm_market_rates',
        locals: { pos_session: @pos_session }
      )
    end
  end

  def update_transfer(transaktion)
    if transaktion.destination_warehouse_id == @pos_session.warehouse_id && transaktion.status == 'sent'
      transaktion.status = 'active'
      notice_message = 'Transpaso de Productos confirmado con exito!'
      if transaktion.update(transaktion_type_params)
        redirect_to pos_session_path(@pos_session), notice: notice_message
      else
        render turbo_stream: turbo_stream.update(
          'confirm_transfer',
          partial: 'shared/forms/form_confirm_transfer',
          locals: { pos_session: @pos_session }
        )
      end
    end
  end

  def update_purchase_credit(transaktion, payment_methods)
    comparison = transaktion_type_params[:receiver_pos_session_id].present? && transaktion.status == 'pending'
    if comparison && transaktion.pos_session.warehouse_id == @pos_session.warehouse_id
      notice_message = 'Compra al credito pagada con exito!'
      transaktion.active!
      if transaktion.update(transaktion_type_params)
        redirect_to pos_session_path(@pos_session), notice: notice_message
      else
        render turbo_stream: turbo_stream.update(
          'paying_transaktion',
          partial: 'shared/forms/form_paying_transaktion',
          locals: { pos_session: @pos_session, transaktion: transaktion,
            payment_methods: payment_methods
          }
        )
      end
    end
  end

  def set_filter_transaktions
    [
      ['Compra al Credito', 'Purchases Credit'], %w[Compra Purchases],
      %w[Venta Sales], %w[Traspaso Transfer], ['Cotización', 'Market rates']
    ]
  end

  def set_payment_methods
    @payment_methods = ['Efectivo', 'Pago QR', 'Tarjeta', 'Transferencia']
  end

  def annullated_transaktion(pos_session, transaktion)
    if params[:annullated] == 'true' && transaktion_type_params[:receiver_pos_session_id].present?
      transaktion.status = 'annulled'
      notice_message = "#{transaktion.type_transaktion_es}, Anulado con Exito!"
      if transaktion.update(transaktion_type_params)
        annulled_inventory(transaktion)
        redirect_to pos_session_transaktion_path(pos_session, transaktion), notice: notice_message
      else
        render turbo_stream: turbo_stream.update(
          'annullated_transaktion',
          partial: 'shared/forms/form_annullated_transaktion',
          locals: { pos_session: pos_session, transaktion: transaktion }
        )
      end
    end
  end

  def annulled_inventory(transaktion)
    if transaktion.type_transaktion == 'Sales' || (transaktion.type_transaktion == 'Market rates' && transaktion.status == 'active')
      transaktion.item_transactions.each do |obj|
        item = Item.find(obj.item_id)
        item.total_stock += obj.qty
        item.quantity += obj.qty / item.product.total_unit
        item.save
        obj.update(stock_at: item.total_stock)
      end
    elsif transaktion.type_transaktion == 'Transfer'
      transaktion.item_transactions.each do |obj|
        item_emitter = Item.find(obj.item_id)
        item_emitter.total_stock += obj.qty
        item_emitter.quantity += obj.qty / item_emitter.product.total_unit
        item_emitter.save
        obj.update(stock_at: item_emitter.total_stock)
        item_receiver = Item.find_by(
          warehouse_id: transaktion.destination_warehouse_id, product_id: item_emitter.product.id
        )
        item_receiver.total_stock -= obj.qty
        item_receiver.quantity -= obj.qty / item_receiver.product.total_unit
        item_receiver.save
      end
    else
      transaktion.item_transactions.each do |obj|
        item = Item.find(obj.item_id)
        item.total_stock -= obj.qty
        item.quantity -= obj.qty / item.product.total_unit
        item.save
        obj.update(stock_at: item.total_stock)
      end
    end
  end
end
