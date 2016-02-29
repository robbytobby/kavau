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
    check_for_missing_informations
  end

  def document
    @document
  end

  def over_address_line
    bounding_box(*style.over_address_line){
      with_custom_font{
        font_size(style.sender_font_size){
          text sender_line, inline_format: true, single_line: true, overflow: :shrink_to_fit
        }
      }
    }
  end

  def with_custom_font
    return yield unless use_custom_font?
    font('CustomFont'){ yield }
  end

  def footer
    fill_color grey
    with_custom_font{
      font_size(style.footer_font_size){
        footer_line(1, footer_line_1)
        footer_line(2, footer_line_2)
        footer_line(3, footer_line_3)
      }
    }
    fill_color '000000'
  end

  private
  
  def check_for_missing_informations
    raise MissingRegisteredSocietyError.new if @model.blank?
    raise MissingInformationError.new(@model) if legal_information_missing? || contacts.none? || default_account.blank?
  end

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
      banking_information,
      registration_information,  
      management_information
    ].flatten.join(' | ')
  end
  
  def footer_line_3
    yellow_text("Ein Projekt im Mietshäuser Syndikat")
  end

  def banking_information
    [ blue_text(default_account.bank), bic_with_explanation, iban_with_explanation ]
  end

  def bic_with_explanation
    [explanation(:bic), default_account.bic].join(' ') 
  end

  def iban_with_explanation
    [explanation(:iban), IBANTools::IBAN.new(default_account.iban).prettify].join(' ')
  end

  def registration_information
    [blue_text(register_court), registration_number,].join(' ')
  end

  def management_information
    "#{blue_text(management_label)} #{manager_names}"
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
    website_url.try(:gsub, /^www/,'' )
  end
  
  def website_url
    Rails.application.config.kavau.general[:website_url]
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

  def config
    @document.config
  end
end
