class PdfSender
  include Prawn::View
  attr_reader :model, :presented

  delegate :legal_form, :contacts, :legal_information_missing?, to: :model
  delegate :name, :full_name, :email, :phone, :register_court, :based_in, :ust_id, :tax_number,
    :bank_details, :street_number, :city_line, :registration_number, to: :presented
  delegate :style, :contact_data, to: :document

  def initialize(project_address, doc)
    @document = doc
    @model = project_address
    @presented = ProjectAddressPresenter.new(@model, self)
  end

  def document
    @document
  end

  def over_address_line
    font_size(style.sender_font_size){
      text_box sender_line, style.over_address_line
      stroke_line style.over_address_line_ruler
    }
  end

  def contact_information
    move_down 40
    font_size(style.contact_information_font_size) {
      contact_data.map{ |string|  contact_line(string) } 
    }
  end

  def footer
    font_size(style.footer_font_size){
      footer_line(1, legal_information_line)
      footer_line(2, management_line)
      footer_line(3, bank_details)
    }
  end

  private
  def footer_line(number, text)
    text_box text, style.footer_line(number)
  end

  def management_line
    raise MissingInformationError.new(@model) if contacts.none?
    "#{management_label}: #{manager_names}"
  end

  def management_label
    I18n.t(key_with_legal_form(@model, :contacts), scope: 'activerecord.attributes')
  end

  def managers
    contacts.map{|contact| AddressPresenter.new(contact, self) }
  end

  def manager_names
    managers.map{ |manager| manager.full_name(:pdf) }.join(', ')
  end

  def legal_information_line
    raise MissingInformationError.new(@model) if legal_information_missing?
    legal_information.join(', ') 
  end

  def legal_information
    [
      full_name, 
      with_explanation('based_in'), 
      register_court,
      with_explanation('registration_number'), 
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
    [full_name, street_number, city_line].join(', ')
  end

  def contact_line(string)
    return if string.blank?
    text string, align: :right
  end
end
