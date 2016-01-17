require 'active_support/concern'

module AsCsv 
  extend ActiveSupport::Concern

  included do
    delegate :csv_columns, to: self
  end

  class_methods do
    def csv_header
      csv_columns.map{ |key| I18n.t(key.to_s, scope: ['csv', name.underscore]) }
    end
  end

  def to_csv
    csv_columns.map{|key| presented.send(key)}
  end
  
  def presented
    "#{self.class}Presenter".constantize.new(self, nil)
  end
end
