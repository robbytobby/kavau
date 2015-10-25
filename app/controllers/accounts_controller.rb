class AccountsController < ApplicationController
  include TypedAssociated
  include LoadAuthorized
  @typed_associated_name = '@address'

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
    @account.update(permitted_params)
    respond_with @account, location: @account.address
  end

  def destroy
    @account.destroy
    respond_with @account, location: @account.address
  end

  private
    def create_params # overwrite LoadAuthorized#permitted_params
      permitted_params.merge(address: @address)
    end
end
