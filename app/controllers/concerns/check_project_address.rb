require 'active_support/concern'

module CheckProjectAddress
  extend ActiveSupport::Concern
  include I18nKeyHelper

  included do
    before_action :setup_flash, only: [:index, :show]
  end

  private
  def check_for_contacs(address)
    flash[:warning] << warning(address, :no_contacts_for) if address.contacts.none?
  end

  def check_legal_information(address)
    return unless address.legal_information_missing?
    flash[:warning] << warning(address, :missing_legal_information, missing_legal_information(address))
  end

  def check_default_account(address)
    return if address.default_account
    flash[:warning] << warning(address, :missing_default_account)
  end

  def warning(address, scope, missing = nil)
    I18n.t key_with_legal_form(address), 
      scope: "addresses.flash.#{scope}", 
      name: address.name, 
      missing: missing
  end

  def setup_flash
    flash[:warning] ||= []
  end
end

