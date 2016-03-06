class SettingsController < ApplicationController
  include Typed
  include LoadAuthorized
  respond_to :html, :js

  def index
    @settings = @settings.order(:number)
    @settings.each(&:valid?)
    respond_with @settings
  end

  def update
    @setting.update(permitted_params)
    respond_with @setting
  end

  def destroy
    @setting.destroy
    flash.now[:notice]= I18n.t('settings.flash.default_set')
    render :update
  end

  private
    def required_params_key # overwrite LoadAuthorized#required_params_key
      @type.underscore.to_sym
    end

end
