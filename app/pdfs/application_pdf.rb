require "prawn/measurement_extensions"
Prawn::Font::AFM.hide_m17n_warning = true

class ApplicationPdf < Prawn::Document
  include ActionView::Helpers::NumberHelper
  include I18nKeyHelper

  def initialize(record)
    super page_options
    @record = record
    setup_instance_variables
    make
  end

  def make
    repeat(:all){logo}
    sender
    recipient
    date
    content
    repeat(:all){footer}
  end

  private
  def setup_instance_variables
    @recipient = CreditorPresenter.new(@record.creditor, self)
    @sender = ProjectAddressPresenter.new(@record.credit_agreement.account.address, self)
    @date = Date.today
    setup_style_variables
  end

  def sender
    font_size(8){
      text_box sender_line, sender_options
      stroke_line [0, 22.4.cm], [8.cm, 22.4.cm] 
    }
  end

  def sender_line
    [@sender.full_name, @sender.street_number, @sender.city_line].join(', ')
  end

  def recipient
    text_box recipient_data, recipient_options
  end

  def recipient_data
    [@recipient.full_name(:pdf), @recipient.street_number, @recipient.city_line, @recipient.country_name].join("\n")
  end
  
  def date
    text_box "#{I18n.l(@date)}", date_options
  end

  def logo
    return unless FileTest.exists?(logo_path)
    bounding_box(logo_box_position, logo_box_options) do
      image logo_path, logo_options 
      move_down 50
      contact_data
    end
  end

  def contact_data
    font_size(10) do
      contact_line Settings.website_url
      contact_line @sender.email
      contact_line @sender.phone
    end
  end

  def contact_line(string)
    return if string.blank?
    text string, align: :right
  end

  def logo_path
    "#{Rails.root}/app/assets/images/logo.png"
  end

  def footer
    font_size(9){
      footer_line(1, legal_information_line)
      footer_line(2, management_line)
      footer_line(3, @sender.bank_details)
    }
  end

  def footer_line(number, text)
    text_box text, footer_options.merge(footer_line_position(number))
  end

  def management_line
    raise MissingInformationError.new(@sender.model) if @sender.contacts.none?
    "#{management_label}: #{manager_names}"
  end

  def management_label
    I18n.t(key_with_legal_form(@sender.model, :contacts), scope: 'activerecord.attributes')
  end

  def managers
    @sender.contacts.map{|contact| AddressPresenter.new(contact, self) }
  end

  def manager_names
    managers.map{ |manager| manager.full_name(:pdf) }.join(', ')
  end

  def legal_information_line
    raise MissingInformationError.new(@sender.model) if @sender.legal_information_missing?
    legal_information.join(', ') 
  end

  def legal_information
    [
      @sender.full_name, 
      with_explanation('based_in'), 
      @sender.register_court,
      with_explanation('registration_number'), 
      with_explanation(tax_information) 
    ]
  end

  def with_explanation(key)
    "#{ProjectAddress.human_attribute_name(key)}: #{@sender.send(key)}"
  end

  def tax_information
    return 'ust_id' unless @sender.ust_id.blank?
    'tax_number'
  end

  def heading(content)
    font('Helvetica', style: :bold){
      text content
    }
  end

  def content
  end

  # styles & positions
  def setup_style_variables
    @pager_width = 5.cm
    @logo_size = 6.cm
    @line_width = 0.1
    default_leading 3
    self.line_width = @line_width
  end

  def page_options
    { 
      page_size: 'A4', 
      page_layout: :portrait,
      top_margin: 6.cm,
      bottom_margin: 3.5.cm,
      left_margin: 2.cm,
      right_margin: 2.cm 
    }
  end 

  def recipient_options
    { at: [0, 22.cm], height: 3.cm, width: 8.cm, overflow: :shrink_to_fit }
  end

  def sender_options
    { at: [0, 22.8.cm], height: 0.7.cm, width: 8.cm, overflow: :shrink_to_fit }
  end

  def date_options
    { 
      at: [bounds.width - date_box_width, 18.cm], 
      width: date_box_width,
      align: :right,
      inline_format: true
    }
  end

  def date_box_width
    4.cm
  end

  def logo_box_position
    [bounds.width - @logo_size, 25.5.cm]
  end

  def logo_box_options
    { :width => @logo_size}
  end

  def logo_options
    { position: :right, fit: [@logo_size, @logo_size] }
  end

  def footer_options
    { width: bounds.width, height: footer_line_height, inline_format: true, overflow: :shrink_to_fit }
  end

  def footer_line_height
    (page.margins[:bottom] - 2.0.cm) / 3
  end

  def footer_line_position(number)
    { at: [0, 0 - number * footer_line_height - 0.8.cm ] }
  end
end

