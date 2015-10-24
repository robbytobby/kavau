require 'active_support/concern'

module Typed
  extend ActiveSupport::Concern
  included do
    before_action :set_type, except: :index
    before_action :set_associated, except: :index
  end

  private
    def set_type
      @type = type.constantize
    end

    def type
      params[:type]
    end

    def set_associated
      instance_variable_set(typed_association, @type.find(get_associated_id))
    end

    def get_associated_id
      params["#{type.underscore}_id"]
    end
end

