class CreditAgreementVersionPresenter < VersionPresenter
  def changes
    h.content_tag(:ul, changeset.map{ |i| ListItem.new(*i).html }.join('').html_safe)
  end
  
  class ListItem
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::NumberHelper
    include ActionView::Helpers::TranslationHelper

    def initialize(key, values)
      @key = key.to_s
      @old = values.first
      @new = values.last
    end

    def html
      content_tag(:li, [human_attribute, formatted_values].join(': '))
    end

    def human_attribute
      CreditAgreement.human_attribute_name(@key)
    end

    def formatted_values
      [old, new].compact.join(' → ')
    end

    def old
      formatter.new(@old).formatted_value
    end

    def new
      formatter.new(@new).formatted_value
    end

    def formatter
      "#{@key.camelize}Formatter".constantize
    end
  end
end

