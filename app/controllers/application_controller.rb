require 'application_responder'

class ApplicationController < ActionController::Base
  include Pundit
  include I18nKeyHelper
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from Prawn::Errors::CannotFit, with: :layout_error
  rescue_from CustomError, with: :rescue_custom_exception
  rescue_from SpreadsheetArchitect::NoDataError, with: :no_data_error

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

    def rescue_custom_exception(exception)
      flash[exception.flash_type] = exception.message unless exception.message.blank?
      redirect_to exception.redirection
    end

    def user_not_authorized
      flash[:alert] = I18n.t('helpers.not_auhtorized')
      redirect_to(request.referrer || root_path)
    end

    def no_data_error
      flash[:warning] = I18n.t('exceptions.no_data_error')
      redirect_to :back
    end

    def layout_error(exception)
      flash[:alert] = I18n.t('exceptions.layout_error')
      redirect_to :back
    end
end
