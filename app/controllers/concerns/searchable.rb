require 'active_support/concern'

module Searchable
  extend ActiveSupport::Concern
  included do
    before_action :set_up_search, only: :index
    before_action :set_collection, only: :index
  end

  private
    def set_up_search
      @q = original.ransack(search_params)
    end

    def set_collection
      instance_variable_set( instance_variable_name(plural: true), @q.result(distinct: true).page(params[:page]) )
    end

    def original
      instance_variable_get( instance_variable_name(plural: true) )
    end

    def search_params
      default_sort.merge(params[:q] || {})
    end

    def default_sort
      {}
    end
end
    
