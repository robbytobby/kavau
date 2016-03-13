require 'active_support/concern'

module AsSpreadsheet
  extend ActiveSupport::Concern

  included do
    include SpreadsheetArchitect
  end

  def spreadsheet_columns
    spreadsheet_values.map{|i| column_definition(*i)}
  end

  private
  def column_definition(symbol)
    [translated_attr(symbol), symbol]
  end
  
  def translated_attr(attr)
    attr = attr.to_s.gsub(/presented_/,'')
    I18n.t attr, scope: [:spreadsheet, :headers, self.class.name.underscore], default: self.class.human_attribute_name(attr)
  end

  def presented
    "#{self.class}Presenter".constantize.new(self, nil)
  end
end

