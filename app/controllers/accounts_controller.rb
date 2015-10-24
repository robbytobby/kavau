class AccountsController < ApplicationController
  before_action :set_type
  before_action :set_address
  include Authorized

  def new
    respond_with @account
  end

  def edit
    respond_with @account
  end

  def create
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
    def account_params
      params.require(:account).permit(policy(@account || Account.new).permitted_params)
    end

    def create_params
      account_params.merge(address: @address)
    end

    def address_params
      {address: @address}
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
