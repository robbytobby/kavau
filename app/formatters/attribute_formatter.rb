class AttributeFormatter
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TranslationHelper

  def initialize(value)
    @value = value
  end
end
