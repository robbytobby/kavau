require 'active_support/concern'

module Searchable
  extend ActiveSupport::Concern
  require 'csv'

  included do
    respond_to :html, :json, :js, :csv
    before_action :set_up_search, only: [:index, :download_csv]
    before_action :set_collection, only: [:index, :download_csv]
  end

  def download_csv
    respond_with @q.result, filename: I18n.t(controller_name, scope: :controller_names), header: klass.csv_header
  end

  private
    def set_up_search
      @q = original.ransack(search_params)
    end

    def set_collection
      instance_variable_set(
        instance_variable_name(plural: true),
        @q.result(distinct: true).page(params[:page])
      )
    end

    def original
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
