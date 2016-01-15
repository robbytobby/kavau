class PdfSender
  include BuildingBlock
  attr_reader :model, :presented

  delegate :legal_form, :contacts, :legal_information_missing?, to: :model
  delegate :name, :full_name, :email, :phone, :register_court, :based_in, :ust_id, :tax_number,
    :default_account, :street_number, :city_line, :registration_number, to: :presented

  def initialize(project_address, doc)
    raise MissingRegisteredSocietyError.new if project_address.blank?
    raise MissingInformationError.new(@model) if legal_information_missing?
    raise MissingInformationError.new(@model) if contacts.none?
    @document = doc
    @model = project_address
    @presented = ProjectAddressPresenter.new(@model, self)
  end

  def document
    @document
  end

  def over_address_line
    bounding_box(*style.over_address_line){
      font("InfoText"){
        font_size(style.sender_font_size){
          text sender_line, inline_format: true, single_line: true, overflow: :shrink_to_fit
        }
      }
    }
  end

  def footer
    fill_color grey
    font("InfoText"){
      font_size(style.footer_font_size){
        footer_line(1, footer_line_1)
        footer_line(2, footer_line_2)
      }
    }
    fill_color '000000'
  end

  private

  def footer_line(number, text)
    text_box text, style.footer_line(number).merge(inline_format: true)
  end

  def footer_line_1 
    [
      blue_text(full_name), 
      street_number, 
      city_line, 
      with_explanation(:phone),
      with_explanation(:email),
      with_explanation(:website, ''),
      with_explanation(tax_information)
    ].compact.join(' | ')
  end

  def footer_line_2
    [ 
      blue_text(default_account.bank), 
      [explanation(:bic), default_account.bic].join(' '), 
      [explanation(:iban), IBANTools::IBAN.new(default_account.iban).prettify].join(' '),
      registration_information,  
      "#{blue_text(management_label)} #{manager_names}"
    ].join(' | ')
  end

  def registration_information
    [blue_text(register_court), registration_number,].join(' ')
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

  def with_explanation(key, seperator=' ')
    return if send(key).blank?
    [explanation(key), send(key)].join(seperator)
  end

  def explanation(key)
    blue_text(I18n.t("pdf.footer.#{key}"))
  end

  def website
    Settings.website_url.gsub(/^www/,'')
  end

  def tax_information
    return 'ust_id' unless ust_id.blank?
    'tax_number'
  end
  
  def sender_line
    ["<color rgb='#{blue}'>#{full_name}</color>", street_number, city_line].map{|string| nowrap(string)}.join(' | ')
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
