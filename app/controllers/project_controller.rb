class ProjectController < ApplicationController
  include CheckProjectAddress

  after_action :verify_authorized, except: :show
  after_action :verify_policy_scoped, only: :show
  before_action :check_configuration, :setup_addresses, :check_presence_of_addresses, :check_addresses_for_contacts, :check_addresses_legal_information, :check_addresses_for_default_account

  def show
    @type = 'ProjectAddress'
    @accounts = policy_scope(Account).project_accounts
    @funds = policy_scope(Fund)
  end

  private
    def setup_addresses
      @addresses = policy_scope(ProjectAddress).includes(:credit_agreements).order(:name)
    end

    def check_configuration
      return if Setting.all.all?(&:valid?)
      flash[:alert] = I18n.t(:settings_invalid, scope: [:addresses, :flash, current_user.role])
      redirect_to settings_path if policy(:setting).index?
    end

    def check_addresses_for_contacts
      @addresses.each{ |add| check_for_contacs(add) }
    end

    def check_addresses_legal_information
      @addresses.each{ |add| check_legal_information(add) }
    end

    def check_addresses_for_default_account
      @addresses.each{ |add| check_default_account(add) }
    end
end
