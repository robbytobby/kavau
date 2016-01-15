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
    repeat(:all){ @logo.draw }
    #repeat(:all){ @sender.contact_information }
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
    }
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

