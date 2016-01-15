require 'active_support/concern'

module BuildingBlock
  extend ActiveSupport::Concern
  include ActionView::Helpers::NumberHelper
  include Prawn::View

  def heading(string)
    font('Helvetica', style: :bold){
      text string
    }
  end

  def date_box
    text_box "#{I18n.l(date)}", style.date
  end

  def blue_text(string)
    "<color rgb='#{blue}'>#{string}</color>"
  end

  def blue
    "009dc3"
  end

  def grey
    "7c7b7f"
  end
end

