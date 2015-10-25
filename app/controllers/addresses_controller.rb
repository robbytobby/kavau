class AddressesController < ApplicationController
  include Typed
  include LoadAuthorized

  def index
    @addresses = @addresses.send(scope).order(:name)
    respond_with @addresses
  end

  def show
    respond_with @address
  end

  def new
    respond_with @address
  end

  def edit
    respond_with @address
  end

  def create
    @address.save
    respond_with @address, location: -> { after_action_path }
  end

  def update
    @address.update(permitted_params)
    respond_with @address, location: -> { after_action_path }
  end

  def destroy
    @address.destroy
    respond_with @address, location: -> { after_action_path }
  end

  private
    def klass # overwrite LoadAuthorized#klass
      @type.constantize
    end

    def scope
      @type.underscore.pluralize
    end

    def required_params_key # overwrite LoadAuthorized#required_params_key
      @type.underscore.to_sym
    end

    def after_action_path
      action_name == 'create' ? send("#{@type.underscore}_path", @address) : session[:back_url]
    end 
end
