require "prawn/measurement_extensions"
Prawn::Font::AFM.hide_m17n_warning = true

class ApplicationPdf < Prawn::Document
  include ActionView::Helpers::NumberHelper
  include I18nKeyHelper
  attr_reader :style, :recipient, :sender, :date

  def initialize(sender, recipient)
    super page_definition
    @date = Date.today
    @sender = PdfSender.new(sender, self)
    @recipient = PdfRecipient.new(recipient, self)
    @style = PdfStyles.new(self)
    @logo = PdfLogo.new(self)
    set_custom_font
    make
  end

  def make
    stroke_color "7c7b7f"
    repeat :all do
      stroke{ horizontal_line(-2.cm, -1.4.cm, at: 6.2.cm) }
      stroke{ horizontal_line(-2.cm, -1.4.cm, at: 16.4.cm) }
      @logo.draw
      @sender.footer
    end
    content
  end

  private
  def content
  end

  def page_definition
    { 
      page_size: 'A4', 
      page_layout: :portrait,
      top_margin: 6.cm,
      bottom_margin: 3.5.cm,
      left_margin: 2.cm,
      right_margin: 2.cm 
    }.merge(background_definition)
  end 

  def background_definition
    return {} unless FileTest.exists?(background_path)
    {background: "#{Rails.root}/app/assets/images/stempel.png"}
  end

  def background_path
    "#{Rails.root}/app/assets/images/stempel.png"
  end

  def set_custom_font
    font_families.update(
      "InfoText" => {
        normal: "public/fonts/infotext_normal.ttf",
        italic: "public/fonts/infotext_italic.ttf",
        bold: "public/fonts/infotext_bold.ttf",
        bold_italic: "public/fonts/infotext_bold_italic.ttf"
      })
  end
end

