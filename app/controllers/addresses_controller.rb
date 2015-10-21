class AddressesController < ApplicationController
  before_action :set_type
  before_action :set_address, only: [:show, :edit, :update, :destroy]
  respond_to :html

  def index
    @addresses = policy_scope(Address).send(scope)
    authorize @addresses
    respond_with @addresses
  end

  def show
    respond_with @address
  end

  def new
    @address = klass.new
    authorize @address
    respond_with @address
  end

  def edit
    respond_with @address
  end

  def create
    @address = klass.new(address_params)
    authorize @address
    @address.save
    respond_with @address, location: -> { after_action_path }
  end

  def update
    @address.update(address_params)
    respond_with @address, location: -> { after_action_path }
  end

  def destroy
    @address.destroy
    respond_with @address, location: -> { after_action_path }
  end

  private
    def set_address
      @address = klass.find(params[:id])
      authorize @address
    end

    def set_type
      @type = params[:type] || 'Address'
    end

    def klass
      @type.constantize
    end

    def klass_symbol
      @type.underscore.to_sym
    end

    def scope
      @type.underscore.pluralize
    end

    def address_params
      params.require(klass_symbol).permit(policy(@address || Address.new).permitted_params)
    end

    def after_action_path
      action_name == 'create' ? send("#{klass_symbol.to_s}_path", @address) : session[:back_url]
    end 
end
