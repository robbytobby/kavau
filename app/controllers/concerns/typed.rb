require 'active_support/concern'

module Typed
  extend ActiveSupport::Concern
  included do
    before_action :set_type
  end

  private
    def set_type
      @type = params[:type]
    end
end
