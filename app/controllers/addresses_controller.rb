class AddressesController < ApplicationController
  before_action :set_type
  before_action :set_address, only: [:show, :edit, :update, :destroy]
  respond_to :html

  def index
    @addresses = Address.send(scope)
    respond_with @addresses
  end

  def show
    respond_with @address
  end

  def new
    @address = klass.new
    respond_with @address
  end

  def edit
  end

  def create
    @address = klass.new(address_params)
    @address.save
    respond_with @address, location: after_action_path
  end

  def update
    @address.update(address_params)
    respond_with @address, location: after_action_path
  end

  def destroy
    @address.destroy
    respond_with @address, location: after_action_path
  end

  private
    def set_address
      @address = klass.find(params[:id])
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
      params.require(klass_symbol).permit(:name, :first_name, :street_number, :city, :country_code, :salutation, :type, :title, :email, :phone, :zip, :notes)
    end

    def after_action_path
      paths[klass_symbol][params[:action].to_sym]
    end 

    def paths
      Hash.new(creditor_paths).merge(project_address: project_address_paths)
    end

    def project_address_paths
      Hash.new(project_path)
    end

    def creditor_paths
      Hash.new(send("#{klass_symbol.to_s}_path", @address)).merge(destroy: creditors_path)
    end
end
