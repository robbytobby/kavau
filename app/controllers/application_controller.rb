require 'application_responder'

class ApplicationController < ActionController::Base
  include Pundit
  include I18nKeyHelper
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from MissingInformationError, with: :missing_address_information
  rescue_from MissingTemplateError, with: :missing_template
  rescue_from MissingRegisteredSocietyError, with: :registered_society_missing

  self.responder = ApplicationResponder
  respond_to :html

  before_action :authenticate_user!
  before_action :set_back_url, only: [:index, :show]
  before_action :set_paper_trail_whodunnit
  after_action :verify_authorized, except: :index, unless: :devise_controller?
  after_action :verify_policy_scoped, only: :index

  protect_from_forgery with: :exception

  private
    def set_back_url
      session[:back_url] = url_for(controller: controller_name,
                                   action: action_name,
                                   only_path: true)
    end

    def user_not_authorized
      flash[:alert] = I18n.t('helpers.not_auhtorized')
      redirect_to(request.referrer || root_path)
    end

    def missing_address_information(exception)
      redirect_to exception.address
    end

    def missing_template(exception)
      flash[:warning] = I18n.t(exception.klass.model_name.singular, scope: [:exceptions, :missing_template_error], year: exception.year)
      redirect_to letters_path
    end

    def registered_society_missing(exception)
      flash[:warning] = I18n.t('exceptions.registered_society_missing')
      redirect_to :back
    end
end
