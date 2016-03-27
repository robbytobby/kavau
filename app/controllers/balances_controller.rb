class BalancesController < ApplicationController
  include Typed
  include LoadAuthorized
  include Searchable
  default_sort ['date desc', 'credit_agreement_id asc']
  respond_to :xlsx
  before_action :set_credit_agreement, except: [:index, :show, :download_csv]

  def index
    respond_with @balances, filename: Balance.model_name.human.pluralize(I18n.locale)
  end

  def show
    send_data @balance.pdf, type: 'application/pdf', disposition: :inline
  end

  def edit
    respond_with @balance
  end

  def update
    mark_manual unless permitted_params[:end_amount].blank?
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

    def mark_manual
      return if permitted_params[:end_amount] == @balance.end_amount
      @balance = @balance.becomes_manual_balance
    end

    def required_params_key # overwrite LoadAuthorized#required_params_key
      @type.underscore.to_sym
    end
end
