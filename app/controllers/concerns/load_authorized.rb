require 'active_support/concern'

module LoadAuthorized
  extend ActiveSupport::Concern
  included do
    before_action :find_collection, only: :index
    before_action :find_record, only: [:show, :edit, :update, :destroy]
    before_action :build_record, only: :new
    before_action :create_record, only: :create
    before_action :authorize_collection, only: :index
    before_action :authorize_record, except: :index
  end

  private
    def find_collection
      instance_variable_set( instance_variable_name(plural: true), policy_scope(klass).all )
    end

    def authorize_collection
      authorize instance_variable_get( instance_variable_name(plural: true) )
    end

    def build_record
      instance_variable_set( instance_variable_name, klass.new )
    end

    def create_record
      instance_variable_set( instance_variable_name, klass.new( create_params ) )
    end

    def authorize_record
      authorize instance_variable_get(instance_variable_name)
    end

    def find_record
      instance_variable_set( instance_variable_name, klass.find(params[:id]) )
    end

    def instance_variable_name(plural: false)
      "@#{plural ? base_name.pluralize : base_name}"
    end

    def klass
     base_name.camelize.constantize 
    end
    
    def base_name
      controller_name.singularize
    end

    def instance_policy
      policy( instance_variable_get(instance_variable_name) || klass.new )
    end

    def permitted_params
      params[base_name].permit(instance_policy.permitted_params)
    end

    def create_params
      permitted_params 
    end
end