class BalancesController < ApplicationController
  include Typed
  include LoadAuthorized
  include Searchable
  default_sort ['date desc', 'credit_agreement_id asc']
  before_action :set_credit_agreement, except: :index

  def index
    respond_with @balances
  end

  def new
    respond_with @balance
  end

  def edit
    respond_with @balance
  end

  def create
    @balance.save
    respond_with @balance, location: @credit_agreement
  end

  def update
    set_balance_type
    @balance.update(permitted_params)
    respond_with @balance, location: @credit_agreement
  end

  def destroy
    @balance.destroy
    respond_with @balance, location: @credit_agreement
  end

  private
    def set_credit_agreement
      @credit_agreement = CreditAgreement.find(params[:credit_agreement_id])
      @balance.credit_agreement = @credit_agreement
    end

    def set_balance_type
      return unless permitted_params[:end_amount]
      return if permitted_params[:end_amount].to_d == @balance.end_amount
      @balance = @balance.becomes(ManualBalance)
      @balance.type  = 'ManualBalance'
    end

    def required_params_key # overwrite LoadAuthorized#required_params_key
      @type.underscore.to_sym
    end

    def create_record
      @balance = @type.constantize.new(create_params)
    end

end
