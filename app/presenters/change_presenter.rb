class ChangePresenter
  include ActionView::Helpers::TagHelper

  def initialize(klass, key, values)
    @klass = klass.constantize
    @key = key.to_s
    @old = values.first
    @new = values.last
  end

  def html
    content_tag(:li, [human_attribute, formatted_values].join(': '))
  end

  private
  def human_attribute
    @klass.human_attribute_name(@key)
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

