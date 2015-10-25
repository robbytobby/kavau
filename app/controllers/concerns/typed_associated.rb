require 'active_support/concern'

module TypedAssociated
  extend ActiveSupport::Concern
  include Typed

  included do
    before_action :set_associated, except: :index
  end

  private
    def set_associated
      instance_variable_set(typed_associated_name, @type.constantize.find(get_associated_id))
    end

    def typed_associated_name
      self.class.instance_variable_get('@typed_associated_name') || '@typed_associated'
    end

    def get_associated_id
      params["#{@type.underscore}_id"]
    end
end

