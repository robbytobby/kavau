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
    bounding_box(logo_box_position, logo_box_options){ image logo_path, logo_options }
  end

  def logo_path
    "#{Rails.root}/app/assets/images/logo.png"
  end

  def footer
    font_size(9){
      text_box legal_information, footer_options.merge(at: [0, 0 - footer_line_height - 0.8.cm ])
      text_box management, footer_options.merge(at: [0, 0 - 2 * footer_line_height - 0.8.cm ])
      text_box @sender.bank_details, footer_options.merge(at: [0, 0 - 3 * footer_line_height - 0.8.cm ])
    }
  end

  def management
    raise MissingInformationError.new(@sender.model) if @sender.model.contacts.none?
    I18n.t(key_with_legal_form(@sender.model, :contacts), scope: 'activerecord.attributes') + ': ' +
      @sender.contacts.map{|contact| [contact.title, contact.first_name, contact.name].join(' ')}.join(', ')
  end

  def legal_information
    raise MissingInformationError.new(@sender.model) if @sender.legal_information_missing?
    [@sender.full_name, with_explanation('based_in'), @sender.register_court,
     with_explanation('registration_number'), with_explanation(tax_information) ].join(', ') 
  end

  def with_explanation(key)
    "#{ProjectAddress.human_attribute_name(key)}: #{@sender.send(key)}"
  end

  def tax_information
    return 'ust_id' unless @sender.ust_id.blank?
    'tax_number'
  end

  def content
  end

  # styles & positions
  def setup_style_variables
    @pager_width = 5.cm
    @logo_size = 6.cm
    @line_width = 0.1
    @date = Date.today
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
    { :width => @logo_size, :height => @logo_size }
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
end

