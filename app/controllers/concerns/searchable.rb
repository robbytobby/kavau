require 'active_support/concern'

module Searchable
  extend ActiveSupport::Concern

  included do
    respond_to :html, :json, :js, :xlsx
    before_action :setup_search, only: [:index, :download_csv]
    before_action :setup_collection, :paginate, only: [:index, :download_csv]
  end

  private
    def setup_search
      @q = get_collection.ransack(search_params)
    end

    def setup_collection
      set_collection(@q.result)
    end

    def set_collection(object)
      instance_variable_set(
        instance_variable_name(plural: true),
        object
      )
    end

    def paginate
      return unless request.format.html?
      set_collection( get_collection.page(params[:page]) )
    end

    def get_collection
      instance_variable_get(instance_variable_name(plural: true))
    end

    def search_params
      default_sort.merge(params[:q] || {})
    end

    def default_sort
      {}
    end

  module ClassMethods
    def default_sort(value)
      define_method :default_sort do
        { 's' => value }
      end
    end
  end
end
