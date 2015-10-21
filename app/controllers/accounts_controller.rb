class AccountsController < ApplicationController
  before_action :set_type
  before_action :set_address
  before_action :set_account, only: [:show, :edit, :update, :destroy]

  def new
    @account = Account.new
    authorize @account
    respond_with @account
  end

  def edit
    respond_with @account
  end

  def create
    @account = Account.new(account_params.merge(address: @address))
    authorize @account
    @account.save
    respond_with @account, location: @account.address
  end

  def update
    @account.update(account_params)
    respond_with @account, location: @account.address
  end

  def destroy
    @account.destroy
    respond_with @account, location: @account.address
  end

  private
    def set_account
      @account = Account.find(params[:id])
      authorize @account
    end

    def account_params
      params.require(:account).permit(policy(@account || Account.new).permitted_params)
    end

    def set_address
      @address = @type.find(get_address_id)
    end

    def set_type
      @type = type.constantize
    end

    def type
      params[:type]
    end

    def get_address_id
      params["#{type.underscore}_id"]
    end
end
