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
    color_text(string, blue)
  end

  def yellow_text(string)
    color_text(string, yellow)
  end

  def color_text(string, color)
    "<color rgb='#{color}'>#{string}</color>"
  end

  def blue
    Letter.config[:colors][:color1]
  end

  def grey
    Letter.config[:colors][:color3]
  end

  def yellow
    Letter.config[:colors][:color2]
  end
end

