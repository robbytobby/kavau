class PdfSender
  include BuildingBlock
  attr_reader :model, :presented

  delegate :legal_form, :contacts, :legal_information_missing?, to: :model
  delegate :name, :full_name, :email, :phone, :register_court, :based_in, :ust_id, :tax_number,
    :default_account, :street_number, :city_line, :registration_number, to: :presented

  def initialize(project_address, doc)
    @document = doc
    @model = project_address
    @presented = ProjectAddressPresenter.new(@model, self)
  end

  def document
    @document
  end

  def over_address_line
    bounding_box(*style.over_address_line){
      font_size(style.sender_font_size){
        text sender_line
        stroke_horizontal_rule
      }
    }
  end

  def contact_information
    move_down 20
    font_size(style.contact_information_font_size) {
      contact_data.map{ |string|  contact_line(string) } 
    }
  end

  def footer
    font_size(style.footer_font_size){
      footer_line(1, legal_information_line)
      footer_line(2, management_line)
      footer_line(3, bank_details_line)
    }
  end

  private
  def contact_data
    [Settings.website_url, sender.email, sender.phone]
  end

  def footer_line(number, text)
    text_box text, style.footer_line(number)
  end

  def bank_details_line
    "<b>#{I18n.t('helpers.bank_details')}:</b> #{bank_details.join(' | ')}"
  end

  def bank_details
    raise MissingInformationError.new(model) unless default_account
    [ 
      default_account.bank, 
      ['BIC:', default_account.bic].join(' '), 
      ['IBAN:', IBANTools::IBAN.new(default_account.iban).prettify].join(' ')
    ]
  end

  def management_line
    raise MissingInformationError.new(@model) if contacts.none?
    "<b>#{management_label}:</b> #{manager_names}"
  end

  def management_label
    I18n.t(key_with_legal_form(@model, :contacts), scope: 'activerecord.attributes')
  end

  def managers
    contacts.map{|contact| AddressPresenter.new(contact, self) }
  end

  def manager_names
    managers.map{ |manager| manager.full_name(:pdf) }.join(' | ')
  end

  def legal_information_line
    raise MissingInformationError.new(@model) if legal_information_missing?
    "<b>#{full_name}</b> #{legal_information.join(' | ')}"
  end

  def legal_information
    [
      with_explanation('based_in'), 
      [register_court, registration_number,].join(' '), 
      with_explanation(tax_information) 
    ]
  end

  def with_explanation(key)
    "#{ProjectAddress.human_attribute_name(key)}: #{send(key)}"
  end

  def tax_information
    return 'ust_id' unless ust_id.blank?
    'tax_number'
  end
  
  def sender_line
    [full_name, street_number, city_line].map{|string| nowrap(string)}.join(', ')
  end

  def nowrap(string)
    string.gsub(/ /,nbsp) 
  end

  def nbsp
    Prawn::Text::NBSP
  end

  def contact_line(string)
    return if string.blank?
    text string, align: :right
  end
end
