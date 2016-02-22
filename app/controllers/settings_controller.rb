class SettingsController < ApplicationController
  include Typed
  include LoadAuthorized
  responders :collection
  respond_to :html

  def index
    @settings = @settings.order(:number)
    respond_with @settings
  end

  def update
    @setting.update(permitted_params)
    respond_with @setting
  end

  def destroy
    @setting.destroy
    respond_with @setting
  end

  private
    def required_params_key # overwrite LoadAuthorized#required_params_key
      @type.underscore.to_sym
    end

end
