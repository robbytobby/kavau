require "prawn/measurement_extensions"
Prawn::Font::AFM.hide_m17n_warning = true

class ApplicationPdf < Prawn::Document
  include ActionView::Helpers::NumberHelper
  include I18nKeyHelper
  attr_reader :style

  def initialize(sender, recipient)
    super page_definition
    @date = Date.today
    @sender = PdfSender.new(sender, self)
    @recipient = PdfRecipient.new(recipient, self)
    @style = PdfStyles.new(self)
    @logo = PdfLogo.new(self)
    make
  end

  def make
    repeat(:all){ @logo.draw }
    repeat(:all){ @sender.contact_information }
    @sender.over_address_line
    @recipient.address
    date
    content
    repeat(:all){ @sender.footer }
  end

  def contact_data
    [Settings.website_url, @sender.email, @sender.phone]
  end

  private
  def date
    text_box "#{I18n.l(@date)}", style.date
  end

  def heading(string)
    font('Helvetica', style: :bold){
      text string
    }
  end

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
end

