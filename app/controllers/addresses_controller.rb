class AddressesController < ApplicationController
  include Typed
  include LoadAuthorized
  include Searchable
  include CheckProjectAddress
  default_sort ['name asc', 'first_name asc']
  respond_to :xlsx

  before_action :check_contacts, :legal_information_given?, :default_account_set, only: :show

  def index
    @addresses = @addresses.includes(:credit_agreements)
    respond_with @addresses, filename: Creditor.model_name.human.pluralize(I18n.locale)
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
    def klass
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

    def check_contacts
      return unless @type == 'ProjectAddress'
      check_for_contacs(@address)
    end

    def legal_information_given?
      return unless @type == 'ProjectAddress'
      check_legal_information(@address)
    end

    def default_account_set
      return unless @type == 'ProjectAddress'
      check_default_account(@address)
    end
end
