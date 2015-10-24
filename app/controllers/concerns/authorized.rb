require 'active_support/concern'

module Authorized
  extend ActiveSupport::Concern
  included do
    before_action :find_record, only: [:show, :edit, :update, :destroy]
    before_action :build_record, only: :new
    before_action :create_record, only: :create
    before_action :authorize_record, except: [:index]
  end

  private
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

    def instance_variable_name
      "@#{base_name}"
    end

    def klass
     base_name.camelize.constantize 
    end

    def klass_params
      send(base_name + '_params')
    end

    def base_name
      controller_name.singularize
    end

    def create_params
      klass_params
    end
end
